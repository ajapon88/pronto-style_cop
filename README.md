# Pronto runner for StyleCop

Pronto runner for StyleCop, csharp code analyzer. [What is Pronto?](https://github.com/mmozuras/pronto)

## Configuration

Configuring StyleCop via Settings.StyleCop will work just fine with pronto-style_cop.
You can also specify a custom `Settings.StyleCop` location with the environment variable `PRONTO_STYLECOP_SETTINGS`

## Installation StyleCopCLI

1. Build stylecopcli
```
$ git clone https://github.com/bbadjari/stylecopcli.git
$ cd stylecopcli
$ msbuild
```

2. On the command line:
```
$ mkdir -p /usr/local/opt/stylecopcli
$ cp ./bin/Debug/* /usr/local/opt/StyleCopCLI/
$ printf '%s\n%s' '#!/bin/bash' 'exec $(which mono) /usr/local/opt/StyleCopCLI/StyleCopCLI.exe "$@"' > /usr/local/bin/StyleCopCLI
$ chmod a+x /usr/local/bin/StyleCopCLI
```

## Configuration of pronto-style_cop
Example configuration to call custom style_cop define symbol option:
```
# .pronto.yml
style_cop:
  definitions:
    - DEBUG
    - RELEASE
    - [SYMBOL1, SYMBOL2]
  parallel: 4
```
