plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Zorg ervoor dat deze plugin hier staat
}

android {
    namespace = "com.smet.unda_tracker"
    compileSdk = 33  // Of de versie die je gebruikt
    
    defaultConfig {
        applicationId = "com.smet.unda_tracker"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-auth:21.0.1")
    implementation("com.google.firebase:firebase-firestore:24.0.0") 
}
