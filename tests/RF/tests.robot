** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           SeleniumLibrary

*** Variables ***
${GITHUB_USERNAME}   jfx
${GITHUB_NAME}   FX Soubirou
${GRID_URL}   http://selenium:4444/wd/hub

*** Test Cases ***
Test Robot Framework: [--version] option
    ${rc}    ${output} =    When Run and Return RC and Output    robot --version
    Then Should Be Equal As Integers    ${rc}    251
    And Should Contain    ${output}    Robot Framework

Test Requests library
    Given Create Session  github  https://api.github.com   disable_warnings=1
    ${resp}=  When Get Request  github  /users/${GITHUB_USERNAME}
    Then Should Be Equal As Strings  ${resp.status_code}  200
    And Dictionary Should Contain Value  ${resp.json()}  ${GITHUB_NAME}

Test Selenium library
    Open Browser	 https://www.qwant.com   Chrome 	remote_url=${GRID_URL}
    Input text   name=q   robot framework
    Click Element   class:search_bar__form__search
    Wait Until Page Contains   robotframework.org
    [Teardown]  Close All Browsers

*** Keywords ***
