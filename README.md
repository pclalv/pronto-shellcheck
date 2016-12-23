# Pronto runner for ShellCheck

[![Code Climate](https://codeclimate.com/github/pclalv/pronto-shellcheck.svg)](https://codeclimate.com/github/pclalv/pronto-shellcheck)
[![Build Status](https://travis-ci.org/pclalv/pronto-shellcheck.svg?branch=master)](https://travis-ci.org/pclalv/pronto-shellcheck)


Pronto runner for [ShellCheck](https://www.shellcheck.net). [What is Pronto?](https://github.com/mmozuras/pronto)

## Prerequisites

You'll need to install [shellcheck by yourself](https://github.com/koalaman/shellcheck#installing). If `shellcheck` is in your `PATH`, everything will simply work.

## Configuration

Pass any options you would pass to `shellcheck` with the [`SHELLCHECK_OPTS` environment variable](shellcheck_opts) to `pronto run`; e.g., `SHELLCHECK_OPTS='-x' pronto run`.

[shellcheck_opts]: [https://github.com/koalaman/shellcheck/wiki/Integration#allow-passing-through-or-configuring-the-environment-variable-shellcheck_opts]
