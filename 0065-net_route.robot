*** Settings ***
Documentation    This test configures parameters for "net self" objects on the BIG-IP
Resource    robotframework-f5-tmos.robot

*** Variables ***
${PRIMARY_HOSTNAME}                     %{PRIMARY_HOSTNAME}
${PRIMARY_MGMT_IP}                      %{PRIMARY_MGMT_IP}
${PRIMARY_SSH_USERNAME}                 %{PRIMARY_SSH_USERNAME}
${PRIMARY_SSH_PASSWORD}                 %{PRIMARY_SSH_PASSWORD}
${PRIMARY_HTTP_USERNAME}                %{PRIMARY_HTTP_USERNAME}
${PRIMARY_HTTP_PASSWORD}                %{PRIMARY_HTTP_PASSWORD}
${SECONDARY_HOSTNAME}                   %{SECONDARY_HOSTNAME}
${SECONDARY_MGMT_IP}                    %{SECONDARY_MGMT_IP}
${SECONDARY_SSH_USERNAME}               %{SECONDARY_SSH_USERNAME}
${SECONDARY_SSH_PASSWORD}               %{SECONDARY_SSH_PASSWORD}
${SECONDARY_HTTP_USERNAME}              %{SECONDARY_HTTP_USERNAME}
${SECONDARY_HTTP_PASSWORD}              %{SECONDARY_HTTP_PASSWORD}
${PRIMARY_STATIC_DEFAULT_ROUTE}            %{PRIMARY_STATIC_DEFAULT_ROUTE}
${SECONDARY_STATIC_DEFAULT_ROUTE}            %{SECONDARY_STATIC_DEFAULT_ROUTE}

*** Test Cases ***
Perform BIG-IP Quick Check
    [Documentation]    Verifies that key BIG-IP services are in a ready state
    set log level    trace
    Wait until Keyword Succeeds    12x    15 seconds    Verify All BIG-IP Ready States    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Wait until Keyword Succeeds    12x    15 seconds    Check for BIG-IP Services Waiting to Restart    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    Wait until Keyword Succeeds    12x    15 seconds    Verify All BIG-IP Ready States    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}
    Wait until Keyword Succeeds    12x    15 seconds    Check for BIG-IP Services Waiting to Restart    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}

Create Default Static Routes on the BIG-IP
    [Documentation]    Creates default static routes on the BIG-IP
    set log level    trace
    ${PRIMARY_STATIC_DEFAULT_ROUTE}    to json    ${PRIMARY_STATIC_DEFAULT_ROUTE}
    ${route_partition}    get from dictionary    ${PRIMARY_STATIC_DEFAULT_ROUTE}    partition
    ${route_gateway}    get from dictionary    ${PRIMARY_STATIC_DEFAULT_ROUTE}    gw
    ${route_description}    get from dictionary    ${PRIMARY_STATIC_DEFAULT_ROUTE}    description
    Create Static Default Route Configuration on the BIG-IP    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}    partition=${route_partition}    gateway=${route_gateway}    description=${route_description}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    ${SECONDARY_STATIC_DEFAULT_ROUTE}    to json    ${SECONDARY_STATIC_DEFAULT_ROUTE}
    ${route_partition}    get from dictionary    ${SECONDARY_STATIC_DEFAULT_ROUTE}    partition
    ${route_gateway}    get from dictionary    ${SECONDARY_STATIC_DEFAULT_ROUTE}    gw
    ${route_description}    get from dictionary    ${SECONDARY_STATIC_DEFAULT_ROUTE}    description
    Create Static Default Route Configuration on the BIG-IP    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}    partition=${route_partition}    gateway=${route_gateway}    description=${route_description}

Display Static Route Configuration on the BIG-IP
    [Documentation]    Retrieves the static routes configured on the device; does not retrieve the routing table/effective routes
    set log level    trace
    Display BIG-IP Static Route Configuration   bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    Display BIG-IP Static Route Configuration   bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}

Ping the Gateway for the Default IPv4 Route
    [Documentation]    Pings the next-hop for each static route to ensure its reachable
    set log level    trace
    ${default_route}    To Json    ${PRIMARY_STATIC_DEFAULT_ROUTE}
    ${default_gateway}    get from dictionary    ${default_route}    gw
    wait until keyword succeeds    4x    15 seconds    Ping Host from BIG-IP    bigip_host=${PRIMARY_MGMT_IP}    bigip_username=${PRIMARY_HTTP_USERNAME}    bigip_password=${PRIMARY_HTTP_PASSWORD}    host=${default_gateway}
    Return from Keyword If    '${SECONDARY_MGMT_IP}' == 'false'
    ${default_route}    To Json    ${SECONDARY_STATIC_DEFAULT_ROUTE}
    ${default_gateway}    get from dictionary    ${default_route}    gw
    wait until keyword succeeds    4x    15 seconds    Ping Host from BIG-IP    bigip_host=${SECONDARY_MGMT_IP}    bigip_username=${SECONDARY_HTTP_USERNAME}    bigip_password=${SECONDARY_HTTP_PASSWORD}    host=${default_gateway}
