---
name: Crash report
about: "Create a report for panics"
---

Please answer all the questions with enough information. All issues not following this template will be closed immediately.
If you are not sure if your question is truely a bug in Tutacc, please discuss it [here](https://github.com/tutacc/discussion/issues) first.

1) What version of Tutacc are you using (If you deploy different version on server and client, please explicitly point out)?

2) What's your scenario of using Tutacc? E.g., Watching YouTube videos in Chrome via Socks/VMess proxy.

3) Please attach full panic log.

You may get panic log using command `journalctl -u tutacc` if your system is Linux (systemd).

4) Please attach your configuration file (**Mask IP addresses before submit this issue**).

```javascript
    // Please attach your configuration here.
```

Please review your issue before submitting.
