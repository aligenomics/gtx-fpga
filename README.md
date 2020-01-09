# gtx-fpga

## 介绍
GTX-FPGA产品是由[未来实验室 GTX-Laboratory](http://www.genetalks.com/)开发的全基因组分析加速工具，采用CPU和FPGA协同工作的异构加速技术，利用各自的特性进行基因数据的高性能计算。可以将30X的全基因组数据分析时间从30小时缩短至30分钟；将100X全外显子数据分析时间从6小时缩短至5分钟完成。

本项目演示如何通过阿里云，直接使用GTX-FPGA产品，对30X的NA12878样本数据，进行全基因组数据的分析，实现从原始测序数据到最终变异结果的完整过程，并统计实际消耗成本。

## 前置条件
- 登录[阿里云](https://homenew.console.aliyun.com/)，并确保账号余额大于100元，以便体验完整分析流程。
- 开通[批量计算服务](https://batchcompute.console.aliyun.com/)，用于执行分析任务。
- 开通[OSS对象存储](http://oss.console.aliyun.com/), 用于上传用户自己的测序数据，保存分析结果。
- 创建并保存当前用户的[AccessKey](https://usercenter.console.aliyun.com/), 如果您使用的是**子账号**，请确认具有以上批量计算和OSS的产品
使用权限

## 使用说明
演示的GTX-FPGA分析应用，是由[WDL](http://www.openwdl.org/)流程语言组织编写, 并通过[Cromwell引擎](https://cromwell.readthedocs.io/en/develop/)进行执行。我们将通过使用阿里云云市场的镜像，创建一个云服务器，来帮你快速创建这一套工作环境。

> 阅读更多关于Cromwell + WDL的资料

> - [标准流程描述语言 WDL 阿里云最佳实践](https://developer.aliyun.com/article/716546?spm=a2c6h.12873581.0.0.4f495f97fdGja2&groupCode=genomics)

> - [Cromwell官方文档中关于阿里云批量计算BCS后端的介绍](https://cromwell.readthedocs.io/en/develop/backends/BCS/)


### 1. 创建Cromwell Server
使用云市场镜像，[购买和创建](https://ecs-buy.aliyun.com/) 一台虚拟机，作为用户的Cromwell Server环境。选择具体参数时，可以参考以下配置：
<pre>
配置信息
计费方式：	按量付费
地域：	华北 2 （北京） 随机分配
实例：	通用型 g6 （ecs.g6.large） 2 vCPU 8 GiB
镜像：	BatchCompute Cromwell server v1.4
存储：	
高效云盘 100 GiB 系统盘

网络：	专有网络
带宽：	按使用流量 100 Mbps
安全组：	sg-2zegt************
VPC：	vpc-2ze3***************
交换机：	vsw-2ze***************
</pre>

> 注意：您可以选择**按量付费**模式，在测试结束后，即可关闭机器，不再产生费用。镜像选择**镜像市场**, 机器网络请选择**分配公网IPv4地址**，带宽选择按流量付费。

![png](https://img.alicdn.com/tfs/TB1fcYdtAT2gK0jSZFkXXcIQFXa-2878-1412.png)

### 2. 登录Cromwell Server，完成初始化设置并且启动服务
- 使用步骤1中创建的ECS服务器IP地址，用户名和密码，登录机器
<code>
$ssh root@182.92.206.xxx
</code>

- 运行目录下的**cromwell-server.sh**，进行Cromwell Server的管理
<code>
# ./cromwell-server.sh
cromwell-server.sh - init cromwell config and start/stop service
Usage: cromwell-server.sh [options...] [init/start/stop]
Options:
  --id=STRING           Access id
  --key=STRING          Access key
  --root=STRING         Oss root for cromwell, e.g: oss://my-bucket/cromwell/
  --instance=STRING     default runtime: instance type [ecs.sn1.medium]
  --image=STRING        default runtime: image id [img-ubuntu-vpc]
</code>







### 1. 创建Cromwell Server

### 1. 创建Cromwell Server

