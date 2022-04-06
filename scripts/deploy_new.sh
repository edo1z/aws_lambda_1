aws lambda create-function --region ${REGION} --function-name ${FUNCTION_NAME} \
  --package-type Image \
  --code ImageUri=${ECR_URI}/${REPO_NAME}:${TAG_NAME} \
  --role ${ROLE_ARN}