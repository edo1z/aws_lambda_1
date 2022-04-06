aws lambda update-function-code --region ${REGION} \
  --function-name ${FUNCTION_NAME} \
  --image-uri ${ECR_URI}/${REPO_NAME}:${TAG_NAME}