#!/bin/bash

# SPDX-License-Identifier: MIT
# Copyright (c) 2024 Marko Sarunac
#
# Part of the Orion's Belt project.
# Repository: https://github.com/Expiscor-Group-Ltd/orions-belt

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Global variables
# Allow environment to be set via command line argument or environment variable
if [[ -n "$1" ]]; then
    ENVIRONMENT="$1"
elif [[ -n "$ANSIBLE_ENVIRONMENT" ]]; then
    ENVIRONMENT="$ANSIBLE_ENVIRONMENT"
else
    ENVIRONMENT="development"
    # Set the environment variable for future runs when using default
    export ANSIBLE_ENVIRONMENT="$ENVIRONMENT"
fi

# Validate environment parameter
if [[ "$ENVIRONMENT" != "production" && "$ENVIRONMENT" != "development" && "$ENVIRONMENT" != "staging" ]]; then
    echo -e "${RED}Error: Invalid environment '$ENVIRONMENT'${NC}"
    echo -e "${YELLOW}Valid environments are: production, development, staging${NC}"
    exit 1
fi

VAULT_PASSWORD_FILE=""
USE_VAULT=false
clear
# Function to display menu
show_menu() {
    echo -e "${YELLOW}=== Orion's Belt Ansible Playbook Runner ===${NC}"
    echo ""
    echo -e "${YELLOW}Current Configuration:${NC}"
    echo -e "  Environment: ${CYAN}$ENVIRONMENT${NC}"
    echo -e "  Vault: ${CYAN}$([ "$USE_VAULT" = true ] && echo "Enabled" || echo "Disabled")${NC}"
    
    # Show configuration files being used
    echo -e "  Configuration: ${CYAN}config.yml${NC}"
    if [[ -f "config-$ENVIRONMENT.yml" ]]; then
        echo -e "    ${GREEN}✓ with overrides from config-$ENVIRONMENT.yml${NC}"
    else
        echo -e "    ${YELLOW}⚠ no environment-specific overrides (config-$ENVIRONMENT.yml not found)${NC}"
    fi
    
    # Show hosts file being used
    local hosts_file="hosts-$ENVIRONMENT"
    if [[ -f "$hosts_file" ]]; then
        echo -e "  Inventory: ${CYAN}$hosts_file${NC}"
    else
        echo -e "  Inventory: ${YELLOW}hosts (fallback - $hosts_file not found)${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Available Categories:${NC}"
    echo "1. Security Hardening Playbooks"
    echo "2. Custom Playbooks"
    echo "3. Configuration Management"
    echo "4. Exit"
    echo ""
}

# Function to configure environment
configure_environment() {
    echo -e "${GREEN}=== Configuration Management ===${NC}"
    echo ""
    echo -e "${YELLOW}Current Settings:${NC}"
    echo "  Environment: $ENVIRONMENT"
    echo "  Vault Password File: ${VAULT_PASSWORD_FILE:-"Not set"}"
    echo ""
    
    # Show configuration files being used
    echo -e "${YELLOW}Configuration Files:${NC}"
    echo -e "  Base config: ${CYAN}config.yml${NC}"
    if [[ -f "config-$ENVIRONMENT.yml" ]]; then
        echo -e "    ${GREEN}✓ Environment overrides: config-$ENVIRONMENT.yml${NC}"
    else
        echo -e "    ${YELLOW}⚠ No environment overrides (config-$ENVIRONMENT.yml not found)${NC}"
    fi
    
    # Show hosts file being used
    echo -e "  Inventory file:"
    local hosts_file="hosts-$ENVIRONMENT"
    if [[ -f "$hosts_file" ]]; then
        echo -e "    ${GREEN}✓ Using: $hosts_file${NC}"
    else
        echo -e "    ${YELLOW}⚠ Using fallback: hosts (environment-specific $hosts_file not found)${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Available Options:${NC}"
    echo "1. Set Environment (development/staging/production)"
    echo "2. Set Vault Password File"
    echo "3. Test Configuration"
    echo "4. Back to Main Menu"
    echo ""
    
    read -p "Enter your choice (1-4): " config_choice
    
    case $config_choice in
        1)
            echo -e "${YELLOW}Available Environments:${NC}"
            echo "1. development"
            echo "2. staging"
            echo "3. production"
            read -p "Enter environment choice (1-3): " env_choice
            case $env_choice in
                1) ENVIRONMENT="development" ;;
                2) ENVIRONMENT="staging" ;;
                3) ENVIRONMENT="production" ;;
                *) echo -e "${RED}Invalid choice. Keeping current environment.${NC}" ;;
            esac
            echo -e "${GREEN}Environment set to: $ENVIRONMENT${NC}"
            ;;
        2)
            read -p "Enter path to vault password file (or press Enter to use interactive): " vault_file
            if [[ -n "$vault_file" ]]; then
                if [[ -f "$vault_file" ]]; then
                    VAULT_PASSWORD_FILE="$vault_file"
                    USE_VAULT=true
                    echo -e "${GREEN}Vault password file set to: $vault_file${NC}"
                else
                    echo -e "${RED}File not found: $vault_file${NC}"
                fi
            else
                VAULT_PASSWORD_FILE=""
                USE_VAULT=true
                echo -e "${GREEN}Will use interactive vault password prompt${NC}"
            fi
            ;;
        3)
            test_configuration
            ;;
        4)
            return
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
}

# Function to test configuration
test_configuration() {
    echo -e "${GREEN}=== Testing Configuration ===${NC}"
    echo ""
    
    # Check if config files exist
    echo -e "${YELLOW}Checking configuration files:${NC}"
    if [[ -f "config.yml" ]]; then
        echo -e "  ${GREEN}✓ config.yml${NC}"
    else
        echo -e "  ${RED}✗ config.yml (missing)${NC}"
    fi
    
    if [[ -f "config-$ENVIRONMENT.yml" ]]; then
        echo -e "  ${GREEN}✓ config-$ENVIRONMENT.yml${NC}"
    else
        echo -e "  ${RED}✗ config-$ENVIRONMENT.yml (missing)${NC}"
    fi
    
    if [[ -f "vault.yml" ]]; then
        echo -e "  ${GREEN}✓ vault.yml${NC}"
        if [[ "$USE_VAULT" = true ]]; then
            echo -e "  ${CYAN}  (encrypted - will prompt for password)${NC}"
        fi
    else
        echo -e "  ${YELLOW}⚠ vault.yml (not found - some playbooks may fail)${NC}"
    fi
    
    # Check if hosts file exists
    echo -e "${YELLOW}Checking inventory file:${NC}"
    local hosts_file="hosts-$ENVIRONMENT"
    local fallback_hosts_file="hosts"
    
    if [[ -f "$hosts_file" ]]; then
        echo -e "  ${GREEN}✓ $hosts_file (environment-specific)${NC}"
        # Count hosts in the environment-specific file
        host_count=$(grep -c "^[[:space:]]*[a-zA-Z]" "$hosts_file" || echo "0")
        echo -e "  ${CYAN}  (contains $host_count host definitions)${NC}"
    elif [[ -f "$fallback_hosts_file" ]]; then
        echo -e "  ${YELLOW}⚠ $fallback_hosts_file (fallback - environment-specific file not found)${NC}"
        # Count hosts in the fallback file
        host_count=$(grep -c "^[[:space:]]*[a-zA-Z]" "$fallback_hosts_file" || echo "0")
        echo -e "  ${CYAN}  (contains $host_count host definitions)${NC}"
        echo -e "  ${YELLOW}  Consider creating $hosts_file for environment-specific hosts${NC}"
    else
        echo -e "  ${RED}✗ No hosts file found (neither $hosts_file nor $fallback_hosts_file)${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Configuration Summary:${NC}"
    echo "  Environment: $ENVIRONMENT"
    echo "  Vault Enabled: $USE_VAULT"
    if [[ -n "$VAULT_PASSWORD_FILE" ]]; then
        echo "  Vault Password File: $VAULT_PASSWORD_FILE"
    fi
}

# Function to build ansible-playbook command
build_ansible_command() {
    local playbook_path="$1"
    local extra_vars="$2"
    
    local cmd="ansible-playbook \"$playbook_path\""
    
    # Add inventory file - use environment-specific hosts file
    local hosts_file="hosts-$ENVIRONMENT"
    if [[ ! -f "$hosts_file" ]]; then
        # Fallback to generic hosts file
        hosts_file="hosts"
    fi
    cmd="$cmd -i \"$hosts_file\""
    
    # Add environment variable
    cmd="$cmd -e \"environment=$ENVIRONMENT\""
    
    # Add extra vars if provided
    if [[ -n "$extra_vars" ]]; then
        cmd="$cmd -e \"$extra_vars\""
    fi
    
    # Add vault options if needed
    if [[ "$USE_VAULT" = true ]]; then
        if [[ -n "$VAULT_PASSWORD_FILE" ]]; then
            cmd="$cmd --vault-password-file \"$VAULT_PASSWORD_FILE\""
        else
            cmd="$cmd --ask-vault-pass"
        fi
    fi
    
    echo "$cmd"
}

# Function to list playbooks in a directory
list_playbooks() {
    local dir="$1"
    local playbooks=()
    
    # Find all .yml and .yaml files, excluding _tasks files
    for file in "$dir"/*.yml "$dir"/*.yaml; do
        # Skip files that don't exist (in case no .yml or .yaml files)
        [[ -f "$file" ]] || continue
        
        # Skip tasks-only files (ending with _tasks.yml or _tasks.yaml)
        if [[ "$file" =~ _tasks\.(yml|yaml)$ ]]; then
            continue
        fi
        
        # Skip configuration files
        if [[ "$file" =~ config.*\.(yml|yaml)$ ]]; then
            continue
        fi
        
        # Get just the filename without path
        filename=$(basename "$file")
        playbooks+=("$filename")
    done
    
    # Display the filtered playbooks
    if [[ ${#playbooks[@]} -eq 0 ]]; then
        echo -e "${RED}No runnable playbooks found in $dir${NC}"
        return 1
    fi
    
    for i in "${!playbooks[@]}"; do
        echo "$((i+1)). ${playbooks[$i]}"
    done
    
    return 0
}

# Function to handle Security Hardening playbooks
handle_security_hardening() {
    echo -e "${GREEN}=== Security Hardening Playbooks ===${NC}"
    echo -e "${CYAN}Environment: $ENVIRONMENT${NC}"
    echo ""
    echo -e "${YELLOW}Available Categories:${NC}"
    echo "1. Filesystem Security"
    echo "2. Boot & System Security"
    echo "3. Network Security"
    echo "4. Authentication & SSH"
    echo "5. System Configuration"
    echo "6. Audit & Logging"
    echo "7. Cron & Task Security"
    echo "8. Main Security Hardening (All-in-one)"
    echo "9. Back to Main Menu"
    echo ""
    
    read -p "Enter your choice (1-9): " sec_choice
    
    case $sec_choice in
        1) list_playbooks "SecurityHardening/filesystem" ;;
        2) list_playbooks "SecurityHardening/boot" ;;
        3) list_playbooks "SecurityHardening/network" ;;
        4) list_playbooks "SecurityHardening/authentication" ;;
        5) list_playbooks "SecurityHardening/system" ;;
        6) list_playbooks "SecurityHardening/audit" ;;
        7) list_playbooks "SecurityHardening/cron" ;;
        8) list_playbooks "SecurityHardening" ;;
        9) return ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
    
    if [[ $? -eq 0 ]]; then
        read -p "Enter the number of the playbook you want to execute: " choice
        read -p "Enter the name of the hosts to execute the playbook on: " hosts
        
        # Determine the correct path based on the category
        case $sec_choice in
            1) playbook_path="SecurityHardening/filesystem" ;;
            2) playbook_path="SecurityHardening/boot" ;;
            3) playbook_path="SecurityHardening/network" ;;
            4) playbook_path="SecurityHardening/authentication" ;;
            5) playbook_path="SecurityHardening/system" ;;
            6) playbook_path="SecurityHardening/audit" ;;
            7) playbook_path="SecurityHardening/cron" ;;
            8) playbook_path="SecurityHardening" ;;
        esac
        
        # Get the playbook filename
        playbooks=()
        for file in "$playbook_path"/*.yml "$playbook_path"/*.yaml; do
            [[ -f "$file" ]] || continue
            if [[ ! "$file" =~ _tasks\.(yml|yaml)$ ]] && [[ ! "$file" =~ config.*\.(yml|yaml)$ ]]; then
                playbooks+=("$(basename "$file")")
            fi
        done
        
        if [[ $choice -gt 0 && $choice -le ${#playbooks[@]} ]]; then
            playbook_to_run="${playbooks[$((choice-1))]}"
            echo -e "${GREEN}Executing $playbook_to_run on hosts $hosts...${NC}"
            echo -e "${CYAN}Environment: $ENVIRONMENT${NC}"
            
            # Build and execute command
            cmd=$(build_ansible_command "$playbook_path/$playbook_to_run" "target_hosts=$hosts")
            echo -e "${YELLOW}Command: $cmd${NC}"
            echo ""
            
            # Execute the command
            eval "$cmd"
        else
            echo -e "${RED}Invalid choice. Exiting.${NC}"
        fi
    fi
}

# Function to handle Custom playbooks
handle_custom() {
    echo -e "${GREEN}=== Custom Playbooks ===${NC}"
    echo -e "${CYAN}Environment: $ENVIRONMENT${NC}"
    echo ""
    
    if list_playbooks "Custom"; then
        read -p "Enter the number of the playbook you want to execute: " choice
        read -p "Enter the name of the hosts to execute the playbook on: " hosts
        
        # Get the playbook filename
        playbooks=()
        for file in Custom/*.yml Custom/*.yaml; do
            [[ -f "$file" ]] || continue
            if [[ ! "$file" =~ _tasks\.(yml|yaml)$ ]] && [[ ! "$file" =~ config.*\.(yml|yaml)$ ]]; then
                playbooks+=("$(basename "$file")")
            fi
        done
        
        if [[ $choice -gt 0 && $choice -le ${#playbooks[@]} ]]; then
            playbook_to_run="${playbooks[$((choice-1))]}"
            echo -e "${GREEN}Executing $playbook_to_run on hosts $hosts...${NC}"
            echo -e "${CYAN}Environment: $ENVIRONMENT${NC}"
            
            # Build and execute command
            cmd=$(build_ansible_command "Custom/$playbook_to_run" "target_hosts=$hosts")
            echo -e "${YELLOW}Command: $cmd${NC}"
            echo ""
            
            # Execute the command
            eval "$cmd"
        else
            echo -e "${RED}Invalid choice. Exiting.${NC}"
        fi
    fi
}

# Function to display help
show_help() {
    echo -e "${BLUE}=== Orion's Belt Ansible Playbook Runner Help ===${NC}"
    echo ""
    echo -e "${YELLOW}Configuration System:${NC}"
    echo "  This script supports the new configuration system with:"
    echo "  - Environment-specific configurations (dev/staging/prod)"
    echo "  - Environment-specific hosts files (hosts-development, hosts-staging, hosts-production)"
    echo "  - Ansible Vault integration for secure credentials"
    echo "  - Centralized configuration management"
    echo ""
    echo -e "${YELLOW}Usage:${NC}"
    echo "  1. Configure environment and vault settings (Option 3)"
    echo "  2. Select playbook category"
    echo "  3. Choose specific playbook"
    echo "  4. Enter target hosts"
    echo ""
    echo -e "${YELLOW}Configuration Files:${NC}"
    echo "  - config.yml: Main configuration"
    echo "  - config-{environment}.yml: Environment overrides"
    echo "  - vault.yml: Encrypted sensitive data"
    echo ""
    echo -e "${YELLOW}Hosts Files:${NC}"
    echo "  - hosts-{environment}: Environment-specific inventory (recommended)"
    echo "  - hosts: Fallback inventory file (intentionally empty)"
    echo ""
    echo -e "${YELLOW}For more information, see: CONFIGURATION.md${NC}"
}

# Main menu loop
while true; do
    show_menu
    read -p "Enter your choice (1-4): " main_choice
    
    case $main_choice in
        1) handle_security_hardening ;;
        2) handle_custom ;;
        3) configure_environment ;;
        4) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid choice. Please try again.${NC}" ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
    clear
done

