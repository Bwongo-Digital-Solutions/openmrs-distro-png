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
    echo "  1) build          Build Docker images"
    echo "  2) run            Build and run containers"
    echo "  3) start          Start existing containers"
    echo "  4) stop           Stop running containers"
    echo "  5) restart        Restart containers"
    echo "  6) update-frontend Copy frontend assets to running container without rebuild"
    echo "  7) prune          Prune stopped containers and unused images"
    echo "  8) prune-all      Prune all unused Docker resources (containers, images, volumes, networks)"
    echo "  9) logs           Show container logs"
    echo "  10) status        Show container status"
    echo "  0) help           Display this help message"
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
        echo "  7) Prune stopped containers"
        echo "  8) Prune all Docker resources"
        echo "  9) Show container logs"
        echo "  10) Show container status"
        echo "  0) Exit"
        echo ""
        read -p "Select an option (0-10): " choice
        echo ""
        
        case $choice in
            1) build ;;
            2) run ;;
            3) start ;;
            4) stop ;;
            5) restart ;;
            6) update_frontend ;;
            7) prune ;;
            8) prune_all ;;
            9) logs ;;
            10) status ;;
            0) 
                echo -e "${GREEN}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option. Please select 0-10.${NC}"
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
    docker-compose build
    echo -e "${GREEN}Build completed successfully!${NC}"
}

# Function to build and run containers
run() {
    echo -e "${GREEN}Building and starting containers...${NC}"
    docker-compose up -d --build
    echo -e "${GREEN}Containers are running!${NC}"
    docker-compose ps
}

# Function to start containers
start() {
    echo -e "${GREEN}Starting containers...${NC}"
    docker-compose up -d
    echo -e "${GREEN}Containers started!${NC}"
    docker-compose ps
}

# Function to stop containers
stop() {
    echo -e "${YELLOW}Stopping containers...${NC}"
    docker-compose down
    echo -e "${GREEN}Containers stopped successfully!${NC}"
}

# Function to restart containers
restart() {
    echo -e "${YELLOW}Restarting containers...${NC}"
    docker-compose restart
    echo -e "${GREEN}Containers restarted successfully!${NC}"
    docker-compose ps
}

# Function to update frontend assets without rebuilding
update_frontend() {
    echo -e "${GREEN}Updating frontend assets...${NC}"
    
    # Get the frontend container name
    CONTAINER_NAME=$(docker-compose ps -q frontend)
    
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
    docker-compose exec frontend nginx -s reload
    
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
    docker-compose logs -f
}

# Function to show status
status() {
    echo -e "${GREEN}Container Status:${NC}"
    docker-compose ps
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
        prune|7)
            prune
            ;;
        prune-all|8)
            prune_all
            ;;
        logs|9)
            logs
            ;;
        status|10)
            status
            ;;
        help|0|*)
            usage
            ;;
    esac
fi
