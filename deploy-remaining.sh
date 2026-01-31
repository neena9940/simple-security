# 1. Navigate to your project
cd ~/simple_security

# 2. Create the script file
cat > deploy-remaining.sh << 'EOF'
#!/bin/bash
# deploy-remaining.sh - Deploy analyzer and dashboard

PROJECT="security-test-001-486007"
REGION="us-central1"

echo "🚀 DEPLOYING REMAINING SERVICES"
echo "==============================="

# Function to deploy service
deploy_service() {
    SERVICE=$1
    PORT=$2
    
    echo ""
    echo "📦 Deploying $SERVICE..."
    
    cd ~/simple_security/$SERVICE
    
    # Build for amd64
    docker build --platform linux/amd64 -t gcr.io/$PROJECT/$SERVICE:v1 .
    
    # Push
    docker push gcr.io/$PROJECT/$SERVICE:v1
    
    # Deploy
    gcloud run deploy $SERVICE \
      --image gcr.io/$PROJECT/$SERVICE:v1 \
      --platform managed \
      --region $REGION \
      --allow-unauthenticated \
      --cpu=1 \
      --memory=256Mi \
      --max-instances=1 \
      --min-instances=0 \
      --port=$PORT \
      --quiet
    
    # Get URL
    URL=$(gcloud run services describe $SERVICE --region=$REGION --format="value(status.url)" 2>/dev/null)
    echo "✅ $SERVICE deployed: $URL"
}

# Deploy analyzer and dashboard
deploy_service "analyzer" "8006"
deploy_service "dashboard" "8007"

# List all services
echo ""
echo "🌐 ALL DEPLOYED SERVICES:"
echo "========================="
gcloud run services list --region=$REGION --format="table(SERVICE,URL)"
EOF

# 3. Make it executable
chmod +x deploy-remaining.sh

# 4. (Optional) Run it to redeploy if needed
# ./deploy-remaining.sh

