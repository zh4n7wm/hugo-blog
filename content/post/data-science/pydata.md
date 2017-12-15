---
categories: ["data-science"]
---

## pandas的plot没有显示所画图片

三种方法解决:

1. import matplotlib.pyplot as plt; plt.show()
2. plt.ion()
3. echo "c.InteractiveShellApp.pylab = 'auto'" >> ~/.ipython/profile_default/ipython_config.py