## 使得打印的结果也包括函数

### what
修改见本次提交

- log_trace之类的都是宏, 调用的是log_log
- 打印内容由stdout_callback和file_callback控制

### why
那些log_trace之类的都是宏, 调用的是log_log, 于是顺着log_log看过去
首先是改了log_Event, 添加了一个字段, func
log_log真正的打印工作(就是我们看到的)是在stdout_callback(看代码, 以及后来搜索发现还有file_callback)中做的, 是这一行:
```
  fprintf(
    ev->udata, "%s %s%-5s\x1b[0m \x1b[90m%s:%d:\x1b[0m ",
    buf, level_colors[ev->level], level_strings[ev->level],
    ev->file, ev->line);

// "%s(时间, buf) %s(CSI颜色字符串)%-5s(级别, 比如DBEUG)\x1b[0m \x1b[90m%s(文件名):%d(行号):\x1b[0m "
```

目前的效果是: 16:44:43 TRACE src/DriveClientAgent.cpp:291: [DriveClientAgent::BackgroundUpdater::update] done
想要的效果是:
16:44:43 TRACE funcname src/DriveClientAgent.cpp:291: [DriveClientAgent::BackgroundUpdater::update] done
因此改成了
```
  fprintf(
    ev->udata, "%s %s%-5s\x1b[0m \x1b[90m%s %s:%d:\x1b[0m ",
    buf, level_colors[ev->level], level_strings[ev->level],
    ev->func, ev->file, ev->line);
```
else的情况也改成了
```
  fprintf(
    ev->udata, "%s %-5s %s %s:%d: ",
    buf, level_strings[ev->level], ev->func, ev->file, ev->line);
```

还有没有别的地方需要改? 那么就搜一下file, 与func字段是并列的
有file_callback, 和else的情况是一样的

### patch
log_trace的调用和它的定义不一致
```
#define log_trace(...) log_log(LOG_TRACE, __FILE__, __LINE__, __func__, __VA_ARGS__)
```


## 怀疑本来就支持文件, 不需要重定向, 怎么才能支持文件?

