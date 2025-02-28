@api @files_sharing-app-required @issue-ocis-1328 @skipOnOcV10.6 @skipOnOcV10.7 @skipOnOcV10.8.0
Feature: a subfolder of a received share can be reshared

  Background:
    Given the administrator has set the default folder for received shares to "Shares"
    And auto-accept shares has been disabled
    And these users have been created with default attributes and without skeleton files:
      | username |
      | Alice    |
      | Brian    |

  @smokeTest @issue-ocis-2214
  Scenario Outline: User is allowed to reshare a sub-folder with the same permissions
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/TMP"
    And user "Alice" has created folder "/TMP/SUB"
    And user "Alice" has shared folder "/TMP" with user "Brian" with permissions "share,read"
    And user "Brian" has accepted share "/TMP" offered by user "Alice"
    When user "Brian" shares folder "/Shares/TMP/SUB" with user "Carol" with permissions "share,read" using the sharing API
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And user "Carol" should be able to accept pending share "<pending_sub_share_path>" offered by user "Brian"
    And as "Carol" folder "/Shares/SUB" should exist
    And as "Brian" folder "/Shares/TMP/SUB" should exist
    @skipOnOcV10.6 @skipOnOcV10.7 @skipOnOcV10.8.0
    Examples:
      | ocs_api_version | ocs_status_code | pending_sub_share_path |
      | 1               | 100             | /SUB                   |
      | 2               | 200             | /SUB                   |

    @skipOnAllVersionsGreaterThanOcV10.8.0 @skipOnOcis
    Examples:
      | ocs_api_version | ocs_status_code | pending_sub_share_path |
      | 1               | 100             | /TMP/SUB               |
      | 2               | 200             | /TMP/SUB               |


  Scenario Outline: User is not allowed to reshare a sub-folder with more permissions
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/TMP"
    And user "Alice" has created folder "/TMP/SUB"
    And user "Alice" has shared folder "/TMP" with user "Brian" with permissions <received_permissions>
    And user "Brian" has accepted share "/TMP" offered by user "Alice"
    When user "Brian" shares folder "/Shares/TMP/SUB" with user "Carol" with permissions <reshare_permissions> using the sharing API
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    And as "Carol" folder "/Shares/SUB" should not exist
    And the sharing API should report to user "Carol" that no shares are in the pending state
    And as "Brian" folder "/Shares/TMP/SUB" should exist
    Examples:
      | ocs_api_version | http_status_code | received_permissions | reshare_permissions |
      # try to pass on more bits including reshare
      | 1               | 200              | 17                   | 19                  |
      | 2               | 404              | 17                   | 19                  |
      | 1               | 200              | 17                   | 21                  |
      | 2               | 404              | 17                   | 21                  |
      | 1               | 200              | 17                   | 23                  |
      | 2               | 404              | 17                   | 23                  |
      | 1               | 200              | 17                   | 31                  |
      | 2               | 404              | 17                   | 31                  |
      | 1               | 200              | 19                   | 23                  |
      | 2               | 404              | 19                   | 23                  |
      | 1               | 200              | 19                   | 31                  |
      | 2               | 404              | 19                   | 31                  |
      # try to pass on more bits but not reshare
      | 1               | 200              | 17                   | 3                   |
      | 2               | 404              | 17                   | 3                   |
      | 1               | 200              | 17                   | 5                   |
      | 2               | 404              | 17                   | 5                   |
      | 1               | 200              | 17                   | 7                   |
      | 2               | 404              | 17                   | 7                   |
      | 1               | 200              | 17                   | 15                  |
      | 2               | 404              | 17                   | 15                  |
      | 1               | 200              | 19                   | 7                   |
      | 2               | 404              | 19                   | 7                   |
      | 1               | 200              | 19                   | 15                  |
      | 2               | 404              | 19                   | 15                  |
      # try to pass on extra delete (including reshare)
      | 1               | 200              | 17                   | 25                  |
      | 2               | 404              | 17                   | 25                  |
      | 1               | 200              | 19                   | 27                  |
      | 2               | 404              | 19                   | 27                  |
      | 1               | 200              | 23                   | 31                  |
      | 2               | 404              | 23                   | 31                  |
      # try to pass on extra delete (but not reshare)
      | 1               | 200              | 17                   | 9                   |
      | 2               | 404              | 17                   | 9                   |
      | 1               | 200              | 19                   | 11                  |
      | 2               | 404              | 19                   | 11                  |
      | 1               | 200              | 23                   | 15                  |
      | 2               | 404              | 23                   | 15                  |

  @issue-ocis-2214
  Scenario Outline: User is allowed to update reshare of a sub-folder with less permissions
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/TMP"
    And user "Alice" has created folder "/TMP/SUB"
    And user "Alice" has shared folder "/TMP" with user "Brian" with permissions "share,create,update,read"
    And user "Brian" has accepted share "/TMP" offered by user "Alice"
    And user "Brian" has shared folder "/Shares/TMP/SUB" with user "Carol" with permissions "share,create,update,read"
    And user "Carol" has accepted share "<pending_sub_share_path>" offered by user "Brian"
    When user "Brian" updates the last share using the sharing API with
      | permissions | share,read |
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And as "Carol" folder "/Shares/SUB" should exist
    But user "Carol" should not be able to upload file "filesForUpload/textfile.txt" to "/Shares/SUB/textfile.txt"
    And as "Brian" folder "/Shares/TMP/SUB" should exist
    And user "Brian" should be able to upload file "filesForUpload/textfile.txt" to "/Shares/TMP/SUB/textfile.txt"
    @skipOnOcV10.6 @skipOnOcV10.7 @skipOnOcV10.8.0
    Examples:
      | ocs_api_version | ocs_status_code | pending_sub_share_path |
      | 1               | 100             | /SUB                   |
      | 2               | 200             | /SUB                   |

    @skipOnAllVersionsGreaterThanOcV10.8.0 @skipOnOcis
    Examples:
      | ocs_api_version | ocs_status_code | pending_sub_share_path |
      | 1               | 100             | /TMP/SUB               |
      | 2               | 200             | /TMP/SUB               |

  @issue-ocis-2214
  Scenario Outline: User is allowed to update reshare of a sub-folder to the maximum allowed permissions
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/TMP"
    And user "Alice" has created folder "/TMP/SUB"
    And user "Alice" has shared folder "/TMP" with user "Brian" with permissions "share,create,update,read"
    And user "Brian" has accepted share "/TMP" offered by user "Alice"
    And user "Brian" has shared folder "/Shares/TMP/SUB" with user "Carol" with permissions "share,read"
    And user "Carol" has accepted share "<pending_sub_share_path>" offered by user "Brian"
    When user "Brian" updates the last share using the sharing API with
      | permissions | share,create,update,read |
    Then the OCS status code should be "<ocs_status_code>"
    And the HTTP status code should be "200"
    And as "Carol" folder "/Shares/SUB" should exist
    And user "Carol" should be able to upload file "filesForUpload/textfile.txt" to "/Shares/SUB/textfile.txt"
    And as "Brian" folder "/Shares/TMP/SUB" should exist
    And user "Brian" should be able to upload file "filesForUpload/textfile.txt" to "/Shares/TMP/SUB/textfile.txt"
    @skipOnOcV10.6 @skipOnOcV10.7 @skipOnOcV10.8.0
    Examples:
      | ocs_api_version | ocs_status_code | pending_sub_share_path |
      | 1               | 100             | /SUB                   |
      | 2               | 200             | /SUB                   |

    @skipOnAllVersionsGreaterThanOcV10.8.0 @skipOnOcis
    Examples:
      | ocs_api_version | ocs_status_code | pending_sub_share_path |
      | 1               | 100             | /TMP/SUB               |
      | 2               | 200             | /TMP/SUB               |

  @issue-ocis-2214
  Scenario Outline: User is not allowed to update reshare of a sub-folder with more permissions
    Given using OCS API version "<ocs_api_version>"
    And user "Carol" has been created with default attributes and without skeleton files
    And user "Alice" has created folder "/TMP"
    And user "Alice" has created folder "/TMP/SUB"
    And user "Alice" has shared folder "/TMP" with user "Brian" with permissions "share,read"
    And user "Brian" has accepted share "/TMP" offered by user "Alice"
    And user "Brian" has shared folder "/Shares/TMP/SUB" with user "Carol" with permissions "share,read"
    And user "Carol" has accepted share "<pending_sub_share_path>" offered by user "Brian"
    When user "Brian" updates the last share using the sharing API with
      | permissions | all |
    Then the OCS status code should be "404"
    And the HTTP status code should be "<http_status_code>"
    And as "Carol" folder "/Shares/SUB" should exist
    But user "Carol" should not be able to upload file "filesForUpload/textfile.txt" to "/Shares/SUB/textfile.txt"
    And as "Brian" folder "/Shares/TMP/SUB" should exist
    But user "Brian" should not be able to upload file "filesForUpload/textfile.txt" to "/Shares/TMP/SUB/textfile.txt"
    @skipOnOcV10.6 @skipOnOcV10.7 @skipOnOcV10.8.0
    Examples:
      | ocs_api_version | http_status_code | pending_sub_share_path |
      | 1               | 200              | /SUB                   |
      | 2               | 404              | /SUB                   |

    @skipOnAllVersionsGreaterThanOcV10.8.0 @skipOnOcis
    Examples:
      | ocs_api_version | http_status_code | pending_sub_share_path |
      | 1               | 200              | /TMP/SUB               |
      | 2               | 404              | /TMP/SUB               |
