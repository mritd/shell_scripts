#!/bin/bash

config_path=`find / -name "mybatis.xml" 2>/dev/null | tail -n 1`

sudo echo "127.0.0.1 www.codesmagic.com" >> /etch/hosts
sudo sed -i 's/KEY=\"\"/KEY=\"305c300d06092a864886f70d0101010500034b003048024100878e6bea07d7052499419efe4ed4382f426dc5ca2d01140f896a6d0566526c6757ff591347d888bd032f94ce92609ce0cc349de0ba9043dc3163f9667438a14d0203010001\"/g' $config_path
sudo sed -i 's/RESULT=\"\"/RESULT=\"\"414834456369b9329793f0b42c6c0af67d00516c7ceb136ad221fa0355dc2cd611ed1bcd36b61d00ba7e587d253c1de145831cd0d65b891c9dc34430f9e69c59/g' $config_path
