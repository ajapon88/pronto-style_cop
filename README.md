# Pronto runner for StyleCop

Pronto runner for StyleCop, csharp code analyzer. [What is Pronto?](https://github.com/mmozuras/pronto)

## Configuration

Configuring StyleCop via Settings.StyleCop will work just fine with pronto-style_cop.
You can also specify a custom `Settings.StyleCop` location with the environment variable `STYLECOP_SETTINGS`

## Installation StyleCopCLI

1. Clone [stylecopcli](https://github.com/bbadjari/stylecopcli.git)
2. Build stylecopcli
```
$ cd stylecopcli
$ msbuild
```
3. On the command line:
```
$ mkdir -p /usr/local/opt/stylecopcli
$ cp ./bin/Debug/* /usr/local/opt/StyleCopCLI/
$ printf '%s\n%s' '#!/bin/bash' 'exec $(which mono) /usr/local/opt/StyleCopCLI/StyleCopCLI.exe "$@"' > /usr/local/bin/StyleCopCLI
$ chmod a+x /usr/local/bin/StyleCopCLI
```
