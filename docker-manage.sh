#!/bin/bash

# Papau New Guinea EMR Docker Management Script
# This script helps manage OpenMRS Docker containers

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${GREEN}Papau New Guinea EMR Docker Management Script${NC}"
    echo ""
    echo "Usage: $0 [COMMAND] or $0 [NUMBER]"
    echo ""
    echo "Commands:"
    echo "  1) build                Build Docker images"
    echo "  2) run                  Build and run containers"
    echo "  3) start                Start existing containers"
    echo "  4) stop                 Stop running containers"
    echo "  5) restart              Restart containers"
    echo "  6) update-frontend      Copy frontend assets to running container without rebuild"
    echo "  7) run-with-grafana     Build and run containers with Grafana monitoring"
    echo "  8) start-grafana        Start containers with Grafana monitoring"
    echo "  9) stop-grafana         Stop all containers including Grafana"
    echo "  10) grafana-status      Show Grafana monitoring status"
    echo "  11) run-ssl-dev         Run with SSL (self-signed certificates for development)"
    echo "  12) run-ssl-prod        Run with SSL (Let's Encrypt for production)"
    echo "  13) start-ssl           Start existing containers with SSL"
    echo "  14) stop-ssl            Stop containers with SSL"
    echo "  15) ssl-status          Show SSL certificate status"
    echo "  16) renew-ssl           Manually renew SSL certificates"
    echo "  17) prune               Prune stopped containers and unused images"
    echo "  18) prune-all           Prune all unused Docker resources"
    echo "  19) logs                Show container logs"
    echo "  20) status              Show container status"
    echo "  0) help                 Display this help message"
    echo ""
}

# Function to display interactive menu
interactive_menu() {
    while true; do
        echo -e "${GREEN}========================================${NC}"
        echo -e "${GREEN}Papau New Guinea EMR Docker Management Script${NC}"
        echo -e "${GREEN}========================================${NC}"
        echo ""
        echo "  1) Build Docker images"
        echo "  2) Build and run containers"
        echo "  3) Start existing containers"
        echo "  4) Stop running containers"
        echo "  5) Restart containers"
        echo "  6) Update frontend assets (no rebuild)"
        echo "  7) Run with Grafana monitoring"
        echo "  8) Start with Grafana monitoring"
        echo "  9) Stop all (including Grafana)"
        echo "  10) Grafana monitoring status"
        echo "  11) Run with SSL (dev - self-signed)"
        echo "  12) Run with SSL (prod - Let's Encrypt)"
        echo "  13) Start with SSL"
        echo "  14) Stop with SSL"
        echo "  15) SSL certificate status"
        echo "  16) Renew SSL certificates"
        echo "  17) Prune stopped containers"
        echo "  18) Prune all Docker resources"
        echo "  19) Show container logs"
        echo "  20) Show container status"
        echo "  0) Exit"
        echo ""
        read -p "Select an option (0-20): " choice
        echo ""
        
        case $choice in
            1) build ;;
            2) run ;;
            3) start ;;
            4) stop ;;
            5) restart ;;
            6) update_frontend ;;
            7) run_with_grafana ;;
            8) start_grafana ;;
            9) stop_grafana ;;
            10) grafana_status ;;
            11) run_ssl_dev ;;
            12) run_ssl_prod ;;
            13) start_ssl ;;
            14) stop_ssl ;;
            15) ssl_status ;;
            16) renew_ssl ;;
            17) prune ;;
            18) prune_all ;;
            19) logs ;;
            20) status ;;
            0) 
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please select 0-20.${NC}"
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        echo ""
    done
}

# Function to build Docker images
build() {
    echo -e "${GREEN}Building Docker images...${NC}"
    docker compose build
    echo -e "${GREEN}Build completed successfully!${NC}"
}

# Function to build and run containers
run() {
    echo -e "${GREEN}Building and starting containers...${NC}"
    docker compose up -d --build
    echo -e "${GREEN}Containers are running!${NC}"
    docker compose ps
}

# Function to start containers
start() {
    echo -e "${GREEN}Starting containers...${NC}"
    docker compose up -d
    echo -e "${GREEN}Containers started!${NC}"
    docker compose ps
}

# Function to stop containers
stop() {
    echo -e "${YELLOW}Stopping containers...${NC}"
    docker compose down
    echo -e "${GREEN}Containers stopped successfully!${NC}"
}

# Function to restart containers
restart() {
    echo -e "${YELLOW}Restarting containers...${NC}"
    docker compose restart
    echo -e "${GREEN}Containers restarted successfully!${NC}"
    docker compose ps
}

# Function to run with Grafana monitoring
run_with_grafana() {
    echo -e "${GREEN}Building and starting containers with Grafana monitoring...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.grafana.yml up -d --build
    echo -e "${GREEN}Containers are running with Grafana!${NC}"
    echo -e "${YELLOW}Grafana is available at: http://localhost/grafana${NC}"
    echo -e "${YELLOW}Username: admin${NC}"
    echo -e "${YELLOW}Password: Check GRAFANA_ADMIN_PASSWORD in docker-compose.grafana.yml (default: Admin123)${NC}"
    docker compose ps
}

# Function to start with Grafana monitoring
start_grafana() {
    echo -e "${GREEN}Starting containers with Grafana monitoring...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.grafana.yml up -d
    echo -e "${GREEN}Containers started with Grafana!${NC}"
    echo -e "${YELLOW}Grafana is available at: http://localhost/grafana${NC}"
    docker compose ps
}

# Function to stop all containers including Grafana
stop_grafana() {
    echo -e "${YELLOW}Stopping all containers including Grafana...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.grafana.yml down
    echo -e "${GREEN}All containers stopped successfully!${NC}"
}

# Function to show Grafana monitoring status
grafana_status() {
    echo -e "${GREEN}Grafana Monitoring Status:${NC}"
    docker compose -f docker-compose.yml -f docker-compose.grafana.yml ps
    echo ""
    echo -e "${GREEN}Grafana Access:${NC}"
    echo -e "  URL: ${YELLOW}http://localhost/grafana${NC}"
    echo -e "  Username: ${YELLOW}admin${NC}"
    echo -e "  Password: ${YELLOW}Check GRAFANA_ADMIN_PASSWORD env var (default: Admin123)${NC}"
    echo ""
    echo -e "${GREEN}Monitoring Components:${NC}"
    echo -e "  - Loki: Log aggregation"
    echo -e "  - Alloy: Log collection from Docker containers"
    echo -e "  - Grafana: Visualization and dashboards"
}

# Function to run with SSL in development mode (self-signed certificates)
run_ssl_dev() {
    echo -e "${GREEN}Building and starting containers with SSL (development mode)...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.ssl.yml up -d --build
    echo -e "${GREEN}Containers are running with SSL!${NC}"
    echo -e "${YELLOW}Application is available at:${NC}"
    echo -e "  - ${YELLOW}https://localhost/openmrs/spa${NC}"
    echo -e "  - ${YELLOW}https://127.0.0.1/openmrs/spa${NC}"
    echo -e "${YELLOW}Note: Your browser will show a security warning for self-signed certificates.${NC}"
    echo -e "${YELLOW}Click 'Advanced' and proceed to the site.${NC}"
    docker compose ps
}

# Function to run with SSL in production mode (Let's Encrypt)
run_ssl_prod() {
    echo -e "${GREEN}Building and starting containers with SSL (production mode)...${NC}"
    echo -e "${YELLOW}Make sure you have configured the following in your .env file:${NC}"
    echo -e "  - COMPOSE_FILE=docker-compose.yml:docker-compose.ssl.yml"
    echo -e "  - SSL_MODE=prod"
    echo -e "  - CERT_WEB_DOMAINS=your-domain.com"
    echo -e "  - CERT_CONTACT_EMAIL=admin@your-domain.com"
    echo ""
    read -p "Have you configured the .env file? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker compose -f docker-compose.yml -f docker-compose.ssl.yml up -d --build
        echo -e "${GREEN}Containers are running with SSL (Let's Encrypt)!${NC}"
        echo -e "${YELLOW}The certbot container will automatically request and configure certificates.${NC}"
        docker compose ps
    else
        echo -e "${YELLOW}SSL setup cancelled. Please configure .env file first.${NC}"
    fi
}

# Function to start with SSL
start_ssl() {
    echo -e "${GREEN}Starting containers with SSL...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.ssl.yml up -d
    echo -e "${GREEN}Containers started with SSL!${NC}"
    docker compose ps
}

# Function to stop containers with SSL
stop_ssl() {
    echo -e "${YELLOW}Stopping containers with SSL...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.ssl.yml down
    echo -e "${GREEN}Containers stopped successfully!${NC}"
}

# Function to show SSL certificate status
ssl_status() {
    echo -e "${GREEN}SSL Certificate Status:${NC}"
    echo ""
    
    # Check if certbot container is running
    CERTBOT_RUNNING=$(docker compose -f docker-compose.yml -f docker-compose.ssl.yml ps -q certbot 2>/dev/null)
    
    if [ -n "$CERTBOT_RUNNING" ]; then
        echo -e "${GREEN}Certbot container is running. Checking certificates...${NC}"
        docker compose -f docker-compose.yml -f docker-compose.ssl.yml exec certbot certbot certificates
    else
        echo -e "${YELLOW}Certbot container is not running. Attempting to check certificates...${NC}"
        docker compose -f docker-compose.yml -f docker-compose.ssl.yml run --rm --entrypoint certbot certbot certificates 2>/dev/null || \
        echo -e "${RED}Unable to check certificates. SSL may not be configured.${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}SSL Container Status:${NC}"
    docker compose -f docker-compose.yml -f docker-compose.ssl.yml ps
}

# Function to manually renew SSL certificates
renew_ssl() {
    echo -e "${YELLOW}Manually renewing SSL certificates...${NC}"
    
    # Check if certbot container is running
    CERTBOT_RUNNING=$(docker compose -f docker-compose.yml -f docker-compose.ssl.yml ps -q certbot 2>/dev/null)
    
    if [ -n "$CERTBOT_RUNNING" ]; then
        echo -e "${GREEN}Using running certbot container...${NC}"
        docker compose -f docker-compose.yml -f docker-compose.ssl.yml exec certbot certbot renew --force-renewal --webroot -w /var/www/certbot
    else
        echo -e "${YELLOW}Certbot container not running. Running one-off renewal...${NC}"
        docker compose -f docker-compose.yml -f docker-compose.ssl.yml run --rm --entrypoint certbot certbot \
            renew --force-renewal --webroot -w /var/www/certbot
    fi
    
    # Reload nginx to pick up new certificates
    echo -e "${YELLOW}Reloading nginx to apply new certificates...${NC}"
    docker compose -f docker-compose.yml -f docker-compose.ssl.yml exec gateway nginx -s reload
    
    echo -e "${GREEN}SSL certificates renewed successfully!${NC}"
}

# Function to update frontend assets without rebuilding
update_frontend() {
    echo -e "${GREEN}Updating frontend assets...${NC}"
    
    # Get the frontend container name
    CONTAINER_NAME=$(docker compose ps -q frontend)
    
    if [ -z "$CONTAINER_NAME" ]; then
        echo -e "${RED}Error: Frontend container is not running!${NC}"
        echo -e "${YELLOW}Please start the containers first using: $0 start${NC}"
        exit 1
    fi
    
    # Copy configuration files
    echo -e "${YELLOW}Copying configuration files...${NC}"
    docker cp frontend/config-core_demo.json $CONTAINER_NAME:/usr/share/nginx/html/config-core_demo.json
    
    # Copy logo and favicon if they exist
    if [ -f "frontend/src/main/resources/logo.png" ]; then
        echo -e "${YELLOW}Copying logo.png...${NC}"
        docker cp frontend/src/main/resources/logo.png $CONTAINER_NAME:/usr/share/nginx/html/logo.png
    fi
    
    if [ -f "frontend/src/main/resources/favicon.ico" ]; then
        echo -e "${YELLOW}Copying favicon.ico...${NC}"
        docker cp frontend/src/main/resources/favicon.ico $CONTAINER_NAME:/usr/share/nginx/html/favicon.ico
    fi
    
    # Reload nginx to pick up changes
    echo -e "${YELLOW}Reloading nginx...${NC}"
    docker compose exec frontend nginx -s reload
    
    echo -e "${GREEN}Frontend assets updated successfully!${NC}"
    echo -e "${GREEN}Changes should be visible immediately (you may need to clear browser cache)${NC}"
}

# Function to prune containers
prune() {
    echo -e "${YELLOW}Pruning stopped containers and unused images...${NC}"
    docker container prune -f
    docker image prune -f
    echo -e "${GREEN}Prune completed!${NC}"
}

# Function to prune all unused Docker resources
prune_all() {
    echo -e "${RED}WARNING: This will remove all unused containers, images, volumes, and networks!${NC}"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Pruning all unused Docker resources...${NC}"
        docker system prune -a --volumes -f
        echo -e "${GREEN}Complete prune finished!${NC}"
    else
        echo -e "${YELLOW}Prune cancelled.${NC}"
    fi
}

# Function to show logs
logs() {
    echo -e "${GREEN}Showing container logs (Ctrl+C to exit)...${NC}"
    docker compose logs -f
}

# Function to show status
status() {
    echo -e "${GREEN}Container Status:${NC}"
    docker compose ps
    echo ""
    echo -e "${GREEN}Docker System Info:${NC}"
    docker system df
}

# Main script logic
if [ $# -eq 0 ]; then
    # No arguments provided, show interactive menu
    interactive_menu
else
    case "${1}" in
        build|1)
            build
            ;;
        run|2)
            run
            ;;
        start|3)
            start
            ;;
        stop|4)
            stop
            ;;
        restart|5)
            restart
            ;;
        update-frontend|6)
            update_frontend
            ;;
        run-with-grafana|7)
            run_with_grafana
            ;;
        start-grafana|8)
            start_grafana
            ;;
        stop-grafana|9)
            stop_grafana
            ;;
        grafana-status|10)
            grafana_status
            ;;
        run-ssl-dev|11)
            run_ssl_dev
            ;;
        run-ssl-prod|12)
            run_ssl_prod
            ;;
        start-ssl|13)
            start_ssl
            ;;
        stop-ssl|14)
            stop_ssl
            ;;
        ssl-status|15)
            ssl_status
            ;;
        renew-ssl|16)
            renew_ssl
            ;;
        prune|17)
            prune
            ;;
        prune-all|18)
            prune_all
            ;;
        logs|19)
            logs
            ;;
        status|20)
            status
            ;;
        help|0|*)
            usage
            ;;
    esac
fi
