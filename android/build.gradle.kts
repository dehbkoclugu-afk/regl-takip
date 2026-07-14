allprojects {
    repositories {
        google()
        // JetBrains'in resmi Maven Central aynası: bu ağda repo.maven.apache.org
        // büyük jar indirmelerinde TLS kopması yaşıyor (bad_record_mac);
        // redirector aynı artifact'ları farklı CDN'den servis eder
        maven("https://cache-redirector.jetbrains.com/maven-central")
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
