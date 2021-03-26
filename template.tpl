___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "MACRO",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "Value Range",
  "categories": ["UTILITY", "TAG_MANAGEMENT", "ANALYTICS"],
  "description": "Provided numeric input is translated into a range with the step size declared in the settings of the variable (e.g.130 \u003d\u003e 101-150, where step size is 50).",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "userInput",
    "displayName": "Input",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": ""
      },
      {
        "type": "REGEX",
        "args": [
          "(^\\d+$)|(^\\d+\\.\\d+$)"
        ],
        "errorMessage": "The input should match the pattern of the positive numeric value"
      }
    ],
    "help": "The input must match a pattern of the positive numeric value. The floating point numbers will be rounded down before converting it to the range."
  },
  {
    "type": "TEXT",
    "name": "stepSize",
    "displayName": "Step Size",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY",
        "errorMessage": "Input value must be a positive integer"
      },
      {
        "type": "POSITIVE_NUMBER",
        "enablingConditions": [],
        "errorMessage": ""
      }
    ],
    "help": "For example, if the input value is 50 and the step size is set to 25, the output will be 26-50."
  },
  {
    "type": "GROUP",
    "name": "moreSettings",
    "displayName": "More Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "CHECKBOX",
        "name": "upperBound",
        "checkboxText": "Enable Upper Bound",
        "simpleValueType": true,
        "help": "For example, if the range upper bound is set to 2000, and the input value is 2500, the output will be 2000+.",
        "defaultValue": false,
        "subParams": [
          {
            "type": "TEXT",
            "name": "upperBoundValue",
            "displayName": "Value",
            "simpleValueType": true,
            "enablingConditions": [
              {
                "paramName": "upperBound",
                "paramValue": true,
                "type": "EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              },
              {
                "type": "REGEX",
                "args": [
                  "(^[2-9]$)|(^[1-9]\\d+$)"
                ],
                "errorMessage": "The value must be an integer and greater than 1"
              }
            ]
          }
        ]
      },
      {
        "type": "CHECKBOX",
        "name": "lowerBound",
        "checkboxText": "Enable Lower Bound",
        "simpleValueType": true,
        "help": "For example, if the range lower bound is set to 20, and the input value is 15, the output will be \u003c20. Default is 1.",
        "subParams": [
          {
            "type": "TEXT",
            "name": "lowerBoundValue",
            "displayName": "Value",
            "simpleValueType": true,
            "enablingConditions": [
              {
                "paramName": "lowerBound",
                "paramValue": true,
                "type": "EQUALS"
              }
            ],
            "valueValidators": [
              {
                "type": "NON_EMPTY"
              },
              {
                "type": "POSITIVE_NUMBER"
              }
            ]
          }
        ],
        "defaultValue": false
      },
      {
        "type": "LABEL",
        "name": "moreSettingsHint",
        "displayName": "If both, the upper bound and the lower bound are enabled, then the upper bound is expected to be greater and has a higher priority in capping the range. If both are equal to to the input value, then the input value will be returned.",
        "enablingConditions": [
          {
            "paramName": "upperBound",
            "paramValue": true,
            "type": "EQUALS"
          },
          {
            "paramName": "lowerBound",
            "paramValue": true,
            "type": "EQUALS"
          }
        ]
      }
    ]
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Enter your template code here.
const Math = require('Math');
const log = require('logToConsole');
const upperBound = data.upperBound;
const upperBoundVal = Math.floor(data.upperBoundValue); 
const lowerBoundVal = Math.floor(data.lowerBoundValue);
const flooredInput = Math.floor(data.userInput);
const stepSize = Math.floor(data.stepSize);

// dummy check block => cancel lowerBound
// dummy check 1 - lowerbound must be !NaN and higher than 1
let lowerBound = data.lowerBound && data.lowerBoundValue > 1;
// dummy check 2 - lowerbound cannot be higher than upperbound
if (lowerBound && upperBound && lowerBoundVal > upperBoundVal) {
  lowerBound = false;
}

if (flooredInput <= 0 || flooredInput >= 0) { // check if input is not NaN
  if(!lowerBound && flooredInput < 1) { // default <1
    return '<1';
  } else if (upperBound && upperBoundVal > 1 && flooredInput > upperBoundVal ) { // upperBoundValue
    return upperBoundVal + '+';
  } else if (lowerBound && flooredInput < lowerBoundVal) { // lowerBoundValue
    return '<' + lowerBoundVal;
  } else if (lowerBound && upperBound && (flooredInput == upperBoundVal && flooredInput == lowerBoundVal)) { // check if input, upperbound and lowerbound values are the same => input
    return flooredInput;
  } else { // try to get range
    if (stepSize <= 1) return flooredInput; // dummy check => pure value instead of range
    if (!stepSize) return undefined; // check NaN
    const upperBound = (Math.ceil(flooredInput / stepSize) * stepSize) || stepSize; // if 0 => stepSize
    const lowerBound = (upperBound - stepSize) + 1;
    return lowerBound.toString() + "-" + upperBound.toString();
  }
}
return undefined;


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: regular-1-1
  code: |-
    const mockData = {
      "userInput":"1",
      "stepSize":"1",
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isAnyOf(1, "1");
- name: regular-1-25
  code: |-
    const mockData = {
      "userInput":"1",
      "stepSize":"25",
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("1-25");
- name: regular-51-50
  code: |-
    const mockData = {
      "userInput":"51",
      "stepSize":"50",
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("51-100");
- name: regular-999-50
  code: |-
    const mockData = {
      "userInput":"999",
      "stepSize":"50",
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("951-1000");
- name: input-less-than-1
  code: |-
    const mockData = {
      "userInput":"-0.09",
      "stepSize":"1",
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("<1");
- name: input-undefined
  code: |-
    const mockData = {
      "userInput":undefined,
      "stepSize":20,
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isUndefined();
- name: stepsize-undefined
  code: |-
    const mockData = {
      "userInput":"11",
      "stepSize":undefined,
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isUndefined();
- name: step-size-less-than-1
  code: |-
    const mockData = {
      "userInput":"1",
      "stepSize":"0.5",
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isAnyOf(1, "1");
- name: defaults-undefined
  code: |-
    const mockData = {
      "userInput":undefined,
      "stepSize":undefined,
      "upperBound":false,
      "lowerBound":false,
    };

    let variableResult = runCode(mockData);
    assertThat(variableResult).isUndefined();
- name: cancel-lowerbound-return-upperbound
  code: |-
    const mockData = {
      "userInput":"15",
      "stepSize":"25",
      "upperBound":true,
      "upperBoundValue":"10",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isFalsy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("10+");
- name: cancel-lowerbound-return-range
  code: |-
    const mockData = {
      "userInput":"8",
      "stepSize":"5",
      "upperBound":true,
      "upperBoundValue":"10",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isFalsy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("6-10");
- name: input-upperbound-lowerbound-equal
  code: |-
    const mockData = {
      "userInput":"5",
      "stepSize":"5",
      "upperBound":true,
      "upperBoundValue":"5",
      "lowerBound":true,
      "lowerBoundValue":"5",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isAnyOf(5, "5");
- name: advanced-range-66-17
  code: |-
    const mockData = {
      "userInput":"66",
      "stepSize":"17",
      "upperBound":true,
      "upperBoundValue":"100",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("52-68");
- name: advanced-range-upperbound
  code: |-
    const mockData = {
      "userInput":"101",
      "stepSize":"17",
      "upperBound":true,
      "upperBoundValue":"100",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("100+");
- name: advanced-range-lowerbound
  code: |-
    const mockData = {
      "userInput":"10",
      "stepSize":"20",
      "upperBound":true,
      "upperBoundValue":"100",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("<20");
- name: advanced-upperbound-only
  code: |-
    const mockData = {
      "userInput":"1000",
      "stepSize":"100",
      "upperBound":true,
      "upperBoundValue":"500",
      "lowerBound":false
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isFalsy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("500+");
- name: advanced-range-lowerbound-only
  code: |-
    const mockData = {
      "userInput":"100",
      "stepSize":"100",
      "upperBound":false,
      "lowerBound":true,
      "lowerBoundValue":"100"
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("1-100");
- name: advanced-lowerbound-only-input-0
  code: |-
    const mockData = {
      "userInput":"0",
      "stepSize":"100",
      "upperBound":false,
      "lowerBound":true,
      "lowerBoundValue":"100"
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("<100");
- name: advanced-input-float-comma-constraint-undefined
  code: |-
    const mockData = {
      "userInput":"1,1",
      "stepSize":"17",
      "upperBound":true,
      "upperBoundValue":"100",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isUndefined();
- name: advanced-lowerbound-upperbound-1-constraint
  code: |-
    const mockData = {
      "userInput":"2",
      "stepSize":"20",
      "upperBound":true,
      "upperBoundValue":"1",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isFalsy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isEqualTo("1-20");
- name: advanced-stepsize-1
  code: |-
    const mockData = {
      "userInput":"20",
      "stepSize":"1",
      "upperBound":true,
      "upperBoundValue":"100",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isAnyOf(20, "20");
- name: advanced-stepsize-nan-constraint-undefined
  code: |-
    const mockData = {
      "userInput":"60",
      "stepSize":'-',
      "upperBound":true,
      "upperBoundValue":"100",
      "lowerBound":true,
      "lowerBoundValue":"20",
    };

    const preset = prepare(mockData);
    assertThat(preset.lowerBound).isTruthy();
    let variableResult = runCode(mockData);
    assertThat(variableResult).isUndefined();
setup: "const Math = require('Math');\nconst log = require('logToConsole');\n\n//\
  \ for lowerbound cancellation tests\nconst prepare = function(mockedData) {\n  /**\n\
  \  * presets variables and cancels lowerBound if required\n  * @param {object} -\
  \ user input\n  * @return {object} - pre-set variables as declared in code\n  **/\n\
  \  const _upperBound = mockedData.upperBound;\n  const _upperBoundVal = Math.floor(mockedData.upperBoundValue);\
  \ \n  const _lowerBoundVal = Math.floor(mockedData.lowerBoundValue);\n  const _flooredInput\
  \ = Math.floor(mockedData.userInput);\n  const _stepSize = Math.floor(mockedData.stepSize);\n\
  \  // dummy check 1 - lowerbound must be !NaN and higher than 1\n  let _lowerBound\
  \ = mockedData.lowerBound && _lowerBoundVal > 1;\n  log(_lowerBound);\n  // dummy\
  \ check 2 - lowerbound cannot be higher than upperbound\n  if (_lowerBound && _upperBound\
  \ && _lowerBoundVal > _upperBoundVal) {\n    log('check');\n    _lowerBound = false;\n\
  \  }\n  const input = {\n    \"upperBound\": _upperBound,\n    \"upperBoundVal\"\
  : _upperBoundVal,\n    \"lowerBound\": _lowerBound,    // recalculated\n    \"lowerBoundVal\"\
  : _lowerBoundVal,\n    \"flooredInput\": _flooredInput,\n    \"stepSize\": _stepSize\n\
  \  };\n  return input;\n};"


___NOTES___

Created on 16/02/2021, 15:42:45


