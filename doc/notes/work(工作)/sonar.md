安装 SonarScanner https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/

下载[Mac OS X 64-bit](https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.2.0.1873-macosx.zip) 版本



配置环境变量 

```shell
vim ~/.bash_profile
export SONAR_SCANNER_HOME=/yourpath/sonar-scanner-4.2.0.1873-macosx/
source ~/.bash_profile
```



Plugin.sbt

```scala
addSbtPlugin("com.github.mwz" % "sbt-sonar" % "1.3.0")
addSbtPlugin("com.github.sbt" % "sbt-jacoco" % "3.1.0")
```

sonar-project.properties

```properties
# more parameters https://docs.sonarqube.org/display/SONAR/Analysis+Parameters
# must be unique in a given SonarQube instance
sonar.projectKey=com.growingio:growing-marketing
# this is the name and version displayed in the SonarQube UI. Was mandatory prior to SonarQube 6.1.
sonar.projectName=growing-marketing
sonar.projectVersion=1.0
sonar.host.url = http://sonarqube.growingio.com

# Path is relative to the sonar-project.properties file. Replace "\" by "/" on Windows.
# This property is optional if sonar.modules is set.
sonar.sources=app
sonar.tests=test

# set the classes path for sonar findbugs plugin
sonar.java.binaries=target/scala-2.12/classes

# Encoding of the source code. Default is default system encoding
sonar.sourceEncoding=UTF-8

# run `sbt jacoco` to generate the report
sonar.coverage.jacoco.xmlReportPaths=target/scala-2.12/jacoco/report/jacoco.xml
```



Build.sbt

```scala
enablePlugins(JacocoPlugin)
jacocoReportSettings := JacocoReportSettings (
	"Jacoco Coverage Report",
	None,
	JacocoThresholds(),
	Seq(JacocoReportFormats.ScalaHTML, JacocoReportFormats.XML),
	"utf-8"
)
```



扫描项目：

sbt  sonarScan