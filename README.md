# gtx-fpga

## 介绍
GTX-FPGA产品是由[未来实验室 GTX-Laboratory](http://www.genetalks.com/)开发的全基因组分析加速工具，采用CPU和FPGA协同工作的异构加速技术，利用各自的特性进行基因数据的高性能计算。可以将30X的全基因组数据分析时间从30小时缩短至30分钟；将100X全外显子数据分析时间从6小时缩短至5分钟完成。同时变异检测结果，产品的[测评报告](#GTX-WGS产品评估报告)中显示可以和GATK保持高度一致。阿里云和人和未来合作，直接在云上提供GTX-FPGA产品，按照用户作业弹性扩展，按需付费，灵活处理从一到千万任意规模的基因测序样本。

本项目演示如何通过阿里云，直接使用GTX-FPGA产品，对30X的NA12878样本数据，进行全基因组数据的分析，实现从原始测序数据到最终变异结果的完整过程，并统计实际消耗成本。

## 前置条件
- 登录[阿里云](https://homenew.console.aliyun.com/)，并确保账号余额大于100元，以便体验完整分析流程。
- 开通[批量计算服务](https://batchcompute.console.aliyun.com/)，用于执行分析任务。
- 开通[OSS对象存储](http://oss.console.aliyun.com/), 用于上传用户自己的测序数据，保存分析结果。创建bucket，例如 gtx-wgs-demo
- 查看或者创建的[AccessKey](https://usercenter.console.aliyun.com/), 如果您使用的是**子账号**，请确认具有以上批量计算和OSS的产品
使用权限.复制AccessKey ID（如LTAI8xxxxx), Access Key Secret(如vVGZVE8qUNjxxxxxxxx) 备用。

## 使用说明
项目演示的GTX-FPGA分析应用，是由[WDL](http://www.openwdl.org/)流程语言组织编写, 并通过[Cromwell引擎](https://cromwell.readthedocs.io/en/develop/)进行执行。我们将通过使用阿里云云市场的镜像，创建一个云服务器，来帮你快速创建这一套工作环境。

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

![png](https://img.alicdn.com/tfs/TB1UYx7ulr0gK0jSZFnXXbRRXXa-2818-1372.png)

### 2. 登录Cromwell Server，完成初始化设置并且启动服务
##### 使用步骤1中创建的ECS服务器IP地址，用户名和密码，登录机器。
<pre><code>
$ssh root@182.92.206.xxx
</code></pre>

##### 成功登陆机器后，你可以运行目录下的**cromwell-server.sh**，进行Cromwell Server的管理
<pre><code>
# ./cromwell-server.sh
cromwell-server.sh - init cromwell config and start/stop service
Usage: cromwell-server.sh [options...] [init/start/stop]
Options:
  --id=STRING           Access id
  --key=STRING          Access key
  --root=STRING         Oss root for cromwell, e.g: oss://my-bucket/cromwell/
  --instance=STRING     default runtime: instance type [ecs.sn1.medium]
  --image=STRING        default runtime: image id [img-ubuntu-vpc]
</code></pre>

#### 2.1 初始化设置，并启动服务
使用文档开头准备的用户AK信息和OSS bucket信息，运行以下命令进行初始化设置。成功完成后，服务会自动启动
<pre><code>
# ./cromwell-server.sh init --id=LTAI8xxxxx --key=vVGZVE8qUNjxxxxxxxx --root=oss://gtx-wgs-demo/cromwell/
</code></pre>

#### 2.2 管理Cromwell Server服务
你可以使用**cromwell-server.sh**，来**启动**或者**停止** Cromwell Server服务
<pre><code>
## 停止服务
# ./cromwell-server.sh stop

## 启动服务
# ./cromwell-server.sh stop

## 检查服务状态
# ./cromwell-server.sh status
checking cromwell server status.....
{"cromwell":"48-613cea9-SNAP"} is running!

</code></pre>


### 3. 使用widdler命令行工具，进行WGS样本的分析
在成功启动Cromwell Server后，你只需要使用**widdler**命令来进行全基因数据分析的一系列操作。

#### 3.1 获取GTX-WGS分析流程
<pre><code>
# git clone https://github.com/aligenomics/gtx-fpga.git
# cd gtx-fpga/
# ll
-rw-r--r-- 1 root root 4677 Jan  9 21:23 README.md
-rw-r--r-- 1 root root  201 Jan  9 21:23 gtx_index.inputs.json
-rw-r--r-- 1 root root  552 Jan  9 21:23 gtx_index.wdl
-rw-r--r-- 1 root root 1036 Jan  9 21:23 gtx_index_align_vc.inputs.json
-rw-r--r-- 1 root root 1904 Jan  9 21:23 gtx_index_align_vc.wdl
-rw-r--r-- 1 root root 1029 Jan  9 21:23 gtx_one.inputs.json
-rw-r--r-- 1 root root 1520 Jan  9 21:23 gtx_one.wdl
drwxr-xr-x 2 root root 4096 Jan  9 21:23 tasks/
</code></pre>

项目文件中，**tasks/** 为GTX-FPGA产品提供的所有分析工具，**gtx_index gtx_index_align gtx_one** 为使用这些工具的演示流程：
- **gtx_index**: 输入物种的参考基因组序列文件，建立索引信息
- **gtx_index_align**: 输入物种的参考基因组序列文件，和样本的测序reads，完成从建立索引，序列比对，到变异检测的全过程，共3个独立步骤。
- **gtx_one**: 输入包括索引信息的参考基因组文件，和样本的测序reads，单个步骤整合所有分析，完成从原始数据到变异结果的全过程。

#### 3.2 启动全基因组分析
对于任意WDL格式的分析流程，都包含3部分内容。以**gtx_one**为例：
 1) WDL格式的Workflow文件，如gtx_one.wdl, 包含流程的分析步骤
 2) WDL格式的Task文件，如gtx_one.wdl中引用的tasks/wgs.wdl，包含工具的定义，如输入，输出和参数，以及需要的资源信息
 3) Json格式的inputs文件，如gtx_one.inputs.json 
> 注意：Task也可以直接在Workflow中定义，此时只有WDL和inputs.json 2个文件

**重要提示**：项目中的演示流程，均已经提供直接Demo文件，**用户无需额外准备输入，即可以运行体验**。WGS演示流程中，提供的参考基因组为**hg19**,或者**hg38**, 测序样本为**NA12878**标准品30x的测序数据。

##### 使用**widdler**投递分析任务
<pre><code>
## 本项目中Task定义和Workflow定义是分开的，所以需要先将Task目录打包成zip文件
# zip -r tasks.zip tasks/
## 运行分析任务
# widdler run -t hg19_wgs_one gtx_one.wdl -d tasks.zip gtx_one.inputs.json
No errors found in gtx_one.wdl
Enabling the following additional workflow options:
bcs_workflow_tag:hg19_wgs_one
{
    "status": "Submitted",
    "id": "639b0f8a-f504-4768-b1ce-69f5fecd59c3"
}
</code></pre>
其中"id":**"639b0f8a-f504-4768-b1ce-69f5fecd59c3"** 为分析任务的ID

##### 查看分析任务状态
<pre><code>
## 查看所有投递的分析任务
# widdler query

## 查看指定任务的运行情况
# widdler describe 639b0f8a-f504-4768-b1ce-69f5fecd59c3

## 了解指定任务的元数据，分析任务失败原因
# widdler query -m 639b0f8a-f504-4768-b1ce-69f5fecd59c3
# widdler explain 639b0f8a-f504-4768-b1ce-69f5fecd59c3
</code></pre>

##### 查看分析结果
对于分析完成的作业，你可以在**OSS**中查看，并下载文件结果。**建议使用** [Ossutils](https://help.aliyun.com/document_detail/50452.html)进行文件的操作。
<pre><code>
## 查询输出结果
# widdler query -o 639b0f8a-f504-4768-b1ce-69f5fecd59c3
[
    {
        "gtx_one.alignment": {
            "right": "oss://gtx-wgs-demo/cromwell/gtx_one/hg19_wgs_one/7f3d59f0-e3f8-4f50-888b-6b5e846933b1/call-wgs/example.bam.bai",
            "left": "oss://gtx-wgs-demo/cromwell/gtx_one/hg19_wgs_one/7f3d59f0-e3f8-4f50-888b-6b5e846933b1/call-wgs/example.bam"
        },
        "gtx_one.variants": "oss://gtx-wgs-demo/cromwell/gtx_one/hg19_wgs_one/7f3d59f0-e3f8-4f50-888b-6b5e846933b1/call-wgs/example.vcf"
    }
]

## 下载OSS文件
./ossutil64 cp oss://ali-genomics-scratch-beijing/new/gtx_one/hg19_wgs_one/7f3d59f0-e3f8-4f50-888b-6b5e846933b1/call-wgs/example.vcf .
</code></pre>

### 4. 资源监控和费用统计
对于运行中或者是完成的分析任务，widdler提供对应的命令，帮助用户了解分析步骤的耗时，资源使用情况，以及最终产生的费用。
<pre><code>
## 查看分析流程执行情况和运行时间
# widdler describe 639b0f8a-f504-4768-b1ce-69f5fecd59c3

## 查看资源使用统计
# widdler stat 639b0f8a-f504-4768-b1ce-69f5fecd59c3

## 统计分析成本（账单信息滞后，需要一天后查看）
# widdler billing 
</code></pre>

### 5. 环境清理
在完成所有的测试工作后，如果您不要再保留环境，可以选择在[ECS控制台](https://ecs.console.aliyun.com/)释放该机器。并且在[OSS的控制台](https://oss.console.aliyun.com/)，删除创建的Bucket。这样该项目后续将不会再产生额外的费用。

## 更多分析
#### 外显子数据数据分析

#### 用户自定义分析

#### 使用批量计算服务

## GTX-WGS产品评估报告
#### 性能
#### 准确性
#### 通量

