#!/bin/bash
# Copyright 2021 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance
# with the License. A copy of the License is located at
#
# http://aws.amazon.com/apache2.0/
#
# or in the "LICENSE.txt" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, express or implied. See the License for the specific language governing permissions and
# limitations under the License.

# Usage: ./postinstall.sh [shared_dir]
shared_dir=$1

# install pyxis
git clone https://github.com/NVIDIA/pyxis.git /tmp/pyxis
sudo yum install -y jq squashfs-tools parallel fuse-overlayfs libnvidia-container-tools pigz squashfuse slurm-devel epel-release
export arch=$(uname -m) && sudo -E yum install -y https://github.com/NVIDIA/enroot/releases/download/v3.4.1/enroot-3.4.1-1.el8.${arch}.rpm
export arch=$(uname -m) && sudo -E yum install -y https://github.com/NVIDIA/enroot/releases/download/v3.4.1/enroot+caps-3.4.1-1.el8.${arch}.rpm
cd /tmp/pyxis
sudo CPPFLAGS='-I /opt/slurm/include/' make
sudo CPPFLAGS='-I /opt/slurm/include/' make install

# install enroot
wget -O /tmp/enroot.conf https://raw.githubusercontent.com/aws-samples/aws-parallelcluster-post-install-scripts/pyxis/pyxis/enroot.conf
sudo mkdir -p /etc/enroot

# set shared directory
sed -i "s/ENROOT_CACHE_PATH          \/fsx\/enroot/ENROOT_CACHE_PATH          ${shared_dir}\/enroot" /tmp/enroot.conf
sudo mv /tmp/enroot.conf /etc/enroot/enroot.conf
sudo mkdir -p /opt/slurm/etc/plugstack.conf.d
echo -e 'include /opt/slurm/etc/plugstack.conf.d/*' | sudo tee /opt/slurm/etc/plugstack.conf
sudo ln -fs /usr/local/share/pyxis/pyxis.conf /opt/slurm/etc/plugstack.conf.d/pyxis.conf