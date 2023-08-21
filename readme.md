![logo](./media/sh-banner.png)
=========
[![Maintenance](https://img.shields.io/maintenance/yes/2023.svg?style=flat-square)]()
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)</br>
[![Good First Issues](https://img.shields.io/github/issues/securehats/toolbox/good%20first%20issue?color=important&label=good%20first%20issue&style=flat)](https://github.com/securehats/toolbox/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
[![Needs Feedback](https://img.shields.io/github/issues/securehats/toolbox/needs%20feedback?color=blue&label=needs%20feedback%20&style=flat)](https://github.com/securehats/toolbox/issues?q=is%3Aopen+is%3Aissue+label%3A%22needs+feedback%22)

# Microsoft Sentinel - KQLFunction-ARM

This GitHub action can be used to convert Microsoft Sentinel yaml files to deployable ARM templates.  

### Example 1

> Add the following code block to your Github workflow:

```yaml
name: template
on:
  push:
    paths:
      - samples/**

jobs:
  template:
    name: Asim-ToARM
    runs-on: ubuntu-latest
    steps:
      - name: Check out repository code
        uses: actions/checkout@v3
      - name: SecureHats template
        uses: SecureHats/KQL-ToArm@v0.0.1
        with:
          filesPath: ./samples
          outputFolder: ./output
```

### Inputs

This Action has the following format inputs.

| Name | Req | Type | Description
|-|-|-|-|
| **`filesPath`**  | true | string | Path to the directory containing the log files to convert, relative to the root of the project.<br /> This path is optional and defaults to the project root, in which case all yaml files across the entire project tree will be discovered.
| **`outputFolder`**  | true | string | Path to the directory containing the log files to convert, relative to the root of the project.<br /> This path is optional and defaults to the project root, in which case all yaml files across the entire project tree will be discovered.
| **`returnObject`**  | false | boolean | **IN DEVELLOPMENT** The default value when not set is `false`. When the value is set to `true` a action will return an ARM template as an object instead of one of multiple files.


## Current limitations / Under Development

See backlog

If you encounter any issues, or hae suggestions for improvements, feel free to open an Issue

[Create Issue](../../issues/new/choose)
