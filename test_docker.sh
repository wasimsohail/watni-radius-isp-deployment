#!/bin/bash

# Docker Test Script for WATNI RADIUS ISP System
set -e

echo "========================================================================"
echo "🐳 DOCKER TEST - WATNI RADIUS ISP SYSTEM"
echo "========================================================================"

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    docker-compose down -v 2>/dev/null || true
    docker system prune -f 2>/dev/null || true
}

# Set trap for cleanup
trap cleanup EXIT

echo "🔨 Building Docker image..."
docker-compose build

echo "🚀 Starting container..."
docker-compose up -d

echo "⏰ Waiting for container to be ready..."
sleep 10

# Check if container is running
if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Container failed to start!"
    echo "📋 Container logs:"
    docker-compose logs
    exit 1
fi

echo "✅ Container is running!"

echo "🧪 Running installation script inside container..."
docker-compose exec -T watni-radius bash -c "cd /home/watni/watni-radius && ./install_fixed.sh"

if [ $? -eq 0 ]; then
    echo "✅ install_fixed.sh completed successfully!"
else
    echo "❌ install_fixed.sh failed!"
    echo "📋 Container logs:"
    docker-compose logs --tail=50
    exit 1
fi

echo "🔧 Running setup script..."
docker-compose exec -T watni-radius bash -c "cd /home/watni/watni-radius && ./setup.sh"

if [ $? -eq 0 ]; then
    echo "✅ setup.sh completed successfully!"
else
    echo "❌ setup.sh failed!"
    echo "📋 Container logs:"
    docker-compose logs --tail=50
    exit 1
fi

echo "📊 Running data creation script..."
docker-compose exec -T watni-radius bash -c "cd /home/watni/watni-radius && ./create_data.sh"

if [ $? -eq 0 ]; then
    echo "✅ create_data.sh completed successfully!"
else
    echo "❌ create_data.sh failed!"
    echo "📋 Container logs:"
    docker-compose logs --tail=50
    exit 1
fi

echo "🧪 Testing RADIUS authentication..."
docker-compose exec -T watni-radius bash -c "radtest testuser1 password123 localhost 0 testing123"

if [ $? -eq 0 ]; then
    echo "✅ RADIUS authentication test passed!"
else
    echo "❌ RADIUS authentication test failed!"
    echo "📋 Debugging - checking users in database:"
    docker-compose exec -T watni-radius bash -c "mysql -u radius -pRadiusPassword123! radius -e 'SELECT * FROM radcheck LIMIT 5;'"
fi

echo "🗄️ Testing database connection..."
docker-compose exec -T watni-radius bash -c "mysql -u radius -pRadiusPassword123! radius -e 'SELECT COUNT(*) as user_count FROM wr_users;'"

if [ $? -eq 0 ]; then
    echo "✅ Database connection test passed!"
else
    echo "❌ Database connection test failed!"
fi

echo "📊 Showing system status..."
docker-compose exec -T watni-radius bash -c "sudo systemctl status mariadb freeradius nginx --no-pager -l"

echo ""
echo "========================================================================"
echo "🎉 DOCKER TEST COMPLETED!"
echo "========================================================================"
echo ""
echo "📋 Container Information:"
echo "   • Container Name: watni-radius-isp"
echo "   • RADIUS Auth Port: 1812/udp"
echo "   • RADIUS Acct Port: 1813/udp"
echo "   • Web Server Port: 8080/tcp"
echo ""
echo "🧪 Test Commands:"
echo "   • Connect to container: docker-compose exec watni-radius bash"
echo "   • Test RADIUS: docker-compose exec watni-radius radtest testuser1 password123 localhost 0 testing123"
echo "   • Check database: docker-compose exec watni-radius mysql -u radius -pRadiusPassword123! radius"
echo "   • View logs: docker-compose logs -f"
echo ""
echo "🛑 To stop: docker-compose down -v"