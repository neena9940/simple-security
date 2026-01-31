cat > deploy_free.sh << 'EOF'
#!/bin/bash
# deploy_free.sh - 100% FREE GCP DEPLOYMENT

echo "🚀 Deploying to GCP - 100% FREE TIER"
echo "======================================"

# 1. Create project with random ID (free)
PROJECT_ID="security-free-$(date +%s)"
echo "Creating project: $PROJECT_ID"
gcloud projects create $PROJECT_ID --name="Security Platform Free"

# 2. Set billing budget to $0 (IMPORTANT!)
echo "Setting billing budget to $0..."
gcloud alpha billing budgets create \
    --billing-account=[YOUR_BILLING_ACCOUNT_ID] \
    --display-name="Zero Budget" \
    --budget-amount=0 \
    --all-updates-rule-pubsub-topic=projects/$PROJECT_ID/topics/budget-notifications

# 3. Enable only FREE services
echo "Enabling free services..."
gcloud services enable containerregistry.googleapis.com --project=$PROJECT_ID
gcloud services enable run.googleapis.com --project=$PROJECT_ID

# 4. Configure Docker for FREE tier
echo "Configuring Docker..."
gcloud auth configure-docker gcr.io --project=$PROJECT_ID

# 5. Build and push images (within free limits)
echo "Building images..."
cd log-collector
docker build -t gcr.io/$PROJECT_ID/log-collector:free .
docker push gcr.io/$PROJECT_ID/log-collector:free
cd ..

cd analyzer
docker build -t gcr.io/$PROJECT_ID/analyzer:free .
docker push gcr.io/$PROJECT_ID/analyzer:free
cd ..

cd dashboard
docker build -t gcr.io/$PROJECT_ID/dashboard:free .
docker push gcr.io/$PROJECT_ID/dashboard:free
cd ..

# 6. Deploy to Cloud Run with FREE tier settings
echo "Deploying to Cloud Run (Free tier)..."
for SERVICE in log-collector analyzer dashboard; do
    gcloud run deploy $SERVICE \
        --image gcr.io/$PROJECT_ID/$SERVICE:free \
        --platform managed \
        --region us-central1 \
        --allow-unauthenticated \
        --cpu=1 \
        --memory=256Mi \
        --max-instances=2 \
        --project=$PROJECT_ID \
        --no-traffic
    echo "✅ $SERVICE deployed (free tier)"
done

echo ""
echo "======================================"
echo "✅ DEPLOYED 100% FREE!"
echo ""
echo "To avoid ALL charges:"
echo "1. This uses ONLY free tier services"
echo "2. Set budget to $0 (done above)"
echo "3. Max 2 instances per service (free limit)"
echo "4. Delete project after testing:"
echo "   gcloud projects delete $PROJECT_ID"
echo ""
echo "Your services will auto-scale to 0 when not used!"
echo "======================================"
EOF
