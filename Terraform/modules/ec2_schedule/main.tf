#ON and OFF schedulers

data "aws_iam_policy_document" "turn_ec2_on_scheduler_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "turn_ec2_on_iam_role_for_scheduler" {
  name               = "Scheduler_assume_role"
  assume_role_policy = data.aws_iam_policy_document.turn_ec2_on_scheduler_policy_document.json
}


resource "aws_scheduler_schedule" "turn_ec2_on_lambda_scheduler" {
  name = "turn-ec2-on-lambda-scheduler"
  group_name = "default"
  schedule_expression = "cron(0 0 0 * 2-6 *)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.turn_ec2_on_lambda_function.arn
    role_arn = aws_iam_role.turn_ec2_on_iam_role_for_scheduler.arn
  }
}


resource "aws_iam_policy" "turn_ec2_on_lambda_policy" {
  name               = "turn-ec2-on-lambda-policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          format("%s:*", aws_lambda_function.turn_ec2_on_lambda_function.arn),
          aws_lambda_function.turn_ec2_on_lambda_function.arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "turn_ec2_on_lambda_policy_attachment" {
  role       = aws_iam_role.turn_ec2_on_iam_role_for_scheduler.name
  policy_arn = aws_iam_policy.turn_ec2_on_lambda_policy.arn
}



data "aws_iam_policy_document" "turn_ec2_off_scheduler_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "turn_ec2_off_iam_role_for_scheduler" {
  name               = "Scheduler_assume_role"
  assume_role_policy = data.aws_iam_policy_document.turn_ec2_off_scheduler_policy_document.json
}


resource "aws_scheduler_schedule" "turn_ec2_off_lambda_scheduler" {
  name = "turn-ec2-off-lambda-scheduler"
  group_name = "default"
  schedule_expression = "cron(0 0 0 * 2-6 *)"
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = aws_lambda_function.turn_ec2_off_lambda_function.arn
    role_arn = aws_iam_role.turn_ec2_off_iam_role_for_scheduler.arn
  }
}


resource "aws_iam_policy" "turn_ec2_off_lambda_policy" {
  name               = "turn-ec2-off-lambda-policy"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "lambda:InvokeFunction"
        ]
        Resource = [
          format("%s:*", aws_lambda_function.turn_ec2_off_lambda_function.arn),
          aws_lambda_function.turn_ec2_off_lambda_function.arn
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "turn_ec2_off_lambda_policy_attachment" {
  role       = aws_iam_role.turn_ec2_off_iam_role_for_scheduler.name
  policy_arn = aws_iam_policy.turn_ec2_off_lambda_policy.arn
}




#Lambda permissions & IAM

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "iam_role_for_lambda_function" {
  name               = "lambda_iam_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}


resource "aws_iam_policy" "allow_to_manipulate_ec2" {
  name = "allow_lambda_to_manipulate_ec2_state"

  policy = jsonencode(
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:DescribeInstances",
        ],
        "Effect": "Allow",
        "Resource": "*" #You should specify your EC2 instances here
      },
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:*:*:*"
      }
    ]
  }
  )
}


resource "aws_iam_role_policy_attachment" "allow_to_manipulate_ec2_policy_attachment" {
  role       = aws_iam_role.iam_role_for_lambda_function.name
  policy_arn = aws_iam_policy.allow_to_manipulate_ec2.arn
}


#Lambda functions

data "archive_file" "turn_ec2_on_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/turn_ec2_on_lambda_function.py"
  output_path = "${path.module}/turn_ec2_on_lambda_function.zip"
}

resource "aws_lambda_function" "turn_ec2_on_lambda_function" {
  function_name    = "turn-ec2-on"
  role             = aws_iam_role.iam_role_for_lambda_function.arn
  filename         = data.archive_file.turn_ec2_on_lambda_function.output_path
  runtime          = "python3.8"
  handler          = "turn_ec2_on.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.turn_ec2_on_lambda_function.output_path)

  environment {
    variables = {
      REGION                   = var.aws_region
    }
  }
}

resource "aws_lambda_permission" "turn_ec2_on_lambda_function_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.turn_ec2_on_lambda_function.function_name
  principal     = "ec2.amazonaws.com"
  source_arn    = aws_scheduler_schedule.turn_ec2_on_lambda_scheduler.arn
}


data "archive_file" "turn_ec2_off_lambda_function" {
  type        = "zip"
  source_file = "${path.module}/turn_ec2_off_lambda_function.py"
  output_path = "${path.module}/turn_ec2_off_lambda_function.zip"
}

resource "aws_lambda_function" "turn_ec2_off_lambda_function" {
  function_name    = "turn-ec2-off"
  role             = aws_iam_role.iam_role_for_lambda_function.arn
  filename         = data.archive_file.turn_ec2_off_lambda_function.output_path
  runtime          = "python3.8"
  handler          = "turn_ec2_off.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.turn_ec2_on_lambda_function.output_path)

  environment {
    variables = {
      REGION                   = var.aws_region
    }
  }
}

resource "aws_lambda_permission" "turn_ec2_off_lambda_function_permission" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.turn_ec2_off_lambda_function.function_name
  principal     = "ec2.amazonaws.com"
  source_arn    = aws_scheduler_schedule.turn_ec2_off_lambda_scheduler.arn
}


#Lambda log groups

resource "aws_cloudwatch_log_group" "turn_ec2_on_lambda_log_group" {
  name = "/aws/lambda/turn-ec2-on"
}

resource "aws_cloudwatch_log_group" "turn_ec2_off_lambda_log_group" {
  name = "/aws/lambda/turn-ec2-off"
}
