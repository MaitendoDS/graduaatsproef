// Dit gedeelte komt eerst voor de repositories en dependencies:
allprojects {
    repositories {
        google()  // Zorg ervoor dat deze repository is toegevoegd
        mavenCentral()
    }
    dependencies {
        // Voeg deze classpath toe voor de Google services plugin
        classpath("com.google.gms:google-services:4.3.15")  // Versie moet kloppen
    }
}

plugins {
    // Voeg de Firebase Google services plugin toe
    id("com.google.gms.google-services") version "4.4.2" apply false
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
