pipeline{
      // 定义groovy脚本中使用的环境变量
      environment{
        // 将构建任务中的构建参数转换为环境变量
		IMAGE_TAG =  sh(returnStdout: true,script: 'echo $image_tag').trim()
		NAMESPACE =  sh(returnStdout: true,script: 'echo $namespace').trim()
		REGION = sh(returnStdout: true,script: 'echo $region').trim()
		REPO =  sh(returnStdout: true,script: 'echo $repo').trim()
		BRANCH =  sh(returnStdout: true,script: 'echo $branch').trim()
      }

      // 定义本次构建使用哪个标签的构建环境，本示例中为 “slave-pipeline”
      agent{
        node{
          label 'slave-pipeline'
        }
      }

      // "stages"定义项目构建的多个模块，可以添加多个 “stage”， 可以多个 “stage” 串行或者并行执行
      stages{
        // 定义第一个stage， 完成克隆源码的任务
        stage('Git'){
          steps{
            git branch: '${BRANCH}', credentialsId: '', url: 'https://github.com/haoshuwei/jenkins-demo.git'
          }
        }

        // 添加第二个stage， 运行源码打包命令
        stage('Package'){
          steps{
              container("maven") {
                  sh "mvn package -B -DskipTests"
              }
          }
        }


        // 添加第三个stage, 运行容器镜像构建和推送命令， 用到了environment中定义的groovy环境变量
        stage('Image Build And Publish'){
          steps{
              container("kaniko") {
                  sh "kaniko -f `pwd`/Dockerfile -c `pwd` --destination=registry-vpc.${REGION}.aliyuncs.com/${NAMESPACE}/${REPO}:${IMAGE_TAG} --skip-tls-verify"
              }
          }
        }

        // 添加第四个stage, 部署应用到指定k8s集群
        stage('Deploy to Kubernetes') {
          steps {
            container('kubectl') {
			  sh "sed -i  's/REGION/${REGION}/g' application-demo.yaml"
			  sh "sed -i  's/NAMESPACE/${NAMESPACE}/g' application-demo.yaml"
			  sh "sed -i  's/REPO/${REPO}/g' application-demo.yaml"
			  sh "sed -i  's/IMAGE_TAG/${IMAGE_TAG}/g' application-demo.yaml"
			  sh "kubectl -n app apply -f  application-demo.yaml"
            }
          }
        }
      }
}