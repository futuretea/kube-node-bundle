#!/bin/bash

# 首先输出 CSV 头
echo "# pod_namespace,pod_name,volume_path,volume_size"

# 获取并处理 volume 信息
du -ahcd 0 /var/lib/kubelet/pods/*/volumes/* 2>/dev/null | sort -rh | while read size path; do
    # 从路径中提取 pod uid
    pod_uid=$(echo $path | grep -o '/pods/[^/]*/volumes' | cut -d'/' -f3)
    
    if [ -n "$pod_uid" ]; then
        # 使用 crictl 通过 label 查找 pod
        pod_info=$(crictl pods --label io.kubernetes.pod.uid=$pod_uid -o json)
        if [ -n "$pod_info" ]; then
            # 直接用 grep 和 cut 解析 JSON
            pod_namespace=$(echo "$pod_info" | grep -o '"namespace": "[^"]*"' | head -1 | cut -d'"' -f4)
            pod_name=$(echo "$pod_info" | grep -o '"name": "[^"]*"' | head -1 | cut -d'"' -f4)
            
            # 输出 CSV 行
            echo "$pod_namespace,$pod_name,$path,$size"
        else
            # Pod 不存在的情况
            echo "DELETED,DELETED,$path,$size"
        fi
    fi
done