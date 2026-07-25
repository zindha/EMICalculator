import com.android.build.api.dsl.ApplicationExtension
import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // Force compileSdk on all Android subprojects (including Flutter plugin modules)
    // to avoid AAR metadata mismatches when plugins are compiled against older SDKs.
    plugins.withId("com.android.application") {
        extensions.findByType<ApplicationExtension>()?.compileSdk = 36
    }
    plugins.withId("com.android.library") {
        extensions.findByType<LibraryExtension>()?.compileSdk = 36
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
