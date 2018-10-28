** Settings ***
Library           Collections
Library           OperatingSystem
Library           RequestsLibrary
Library           SeleniumLibrary

*** Variables ***
${github_username}   jfx
${github_name}   FX Soubirou
${grid_url}   http://node:4444/wd/hub

*** Test Cases ***
Test Robot Framework: [--version] option
    ${rc}    ${output} =    When Run and Return RC and Output    robot --version
    Then Should Be Equal As Integers    ${rc}    251
    And Should Contain    ${output}    Robot Framework

Test Requests library
    Given Create Session  github  https://api.github.com   disable_warnings=1
    ${resp}=  When Get Request  github  /users/${github_username}
    Then Should Be Equal As Strings  ${resp.status_code}  200
    And Dictionary Should Contain Value  ${resp.json()}  ${github_name}

Test Selenium library
    Open Browser	 https://www.google.fr   Chrome 	remote_url=${grid_url}
    Input text   name=q   robot framework
    Press Key	 name=q	 \\27
    Click Element   name=btnI
    Location Should Be   http://robotframework.org/
    [Teardown]  Close All Browsers

*** Keywords ***
