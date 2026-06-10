
// Shared Library Import Kar Rahe Hain
//
// @Library('Shared')
// Jenkins Shared Library ko load karta hai.
//
// Iske andar reusable functions hote hain:
//
// clean_ws()
// clone()
// docker_build()
// docker_push()
// trivy_scan()
//
// Isse code repeat nahi karna padta.

@Library('Shared') _

pipeline {

    // Pipeline kisi bhi available Jenkins Agent par run hogi.
    agent any

    // ==================================================
    // Environment Variables
    // ==================================================
    environment {

        // Main Application Docker Image Name
        DOCKER_IMAGE_NAME = 'ashishkumardev53/easyshop-app'

        // Migration Container Docker Image Name
        DOCKER_MIGRATION_IMAGE_NAME = 'ashishkumardev53/easyshop-migration'

        // Jenkins Build Number ko Docker Tag bana rahe hain.
        //
        // Example:
        // Build #25
        //
        // Docker Tag:
        // easyshop-app:25
        DOCKER_IMAGE_TAG = "${BUILD_NUMBER}"

        // GitHub Credentials Jenkins Credential Store se.
        GITHUB_CREDENTIALS = credentials('github-credentials')

        // Git Branch
        GIT_BRANCH = "master"
    }

    stages {

        // ==================================================
        // Stage 1: Cleanup Workspace
        // ==================================================

        stage('Cleanup Workspace') {

            steps {

                script {

                    // Purana workspace clean karega.
                    //
                    // Previous builds ke files remove honge.
                    // Fresh build environment milega.
                    clean_ws()
                }
            }
        }


        // ==================================================
        // Stage 2: Clone Repository
        // ==================================================

        stage('Clone Repository') {

            steps {

                script {

                    // GitHub se source code download karenge.
                    clone(
                        "https://github.com/ashishkumardev53/tws-e-commerce-app.git",
                        "master"
                    )
                }
            }
        }


        // ==================================================
        // Stage 3: Build Docker Images
        // ==================================================

        stage('Build Docker Images') {

            // Parallel execution
            //
            // Dono images ek saath build hongi.
            // Pipeline fast ho jayegi.
            parallel {

                // ----------------------------------
                // Main Application Image
                // ----------------------------------

                stage('Build Main App Image') {

                    steps {

                        script {

                            docker_build(

                                imageName: env.DOCKER_IMAGE_NAME,

                                imageTag: env.DOCKER_IMAGE_TAG,

                                dockerfile: 'Dockerfile',

                                context: '.'
                            )
                        }
                    }
                }


                // ----------------------------------
                // Migration Image
                // ----------------------------------

                stage('Build Migration Image') {

                    steps {

                        script {

                            docker_build(

                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,

                                imageTag: env.DOCKER_IMAGE_TAG,

                                dockerfile: 'scripts/Dockerfile.migration',

                                context: '.'
                            )
                        }
                    }
                }
            }
        }


        // ==================================================
        // Stage 4: Unit Testing
        // ==================================================

        stage('Run Unit Tests') {

            steps {

                script {

                    // Application ke automated tests run honge.
                    //
                    // Agar tests fail:
                    // Pipeline stop
                    //
                    // Agar pass:
                    // Next stage
                    run_tests()
                }
            }
        }


        // ==================================================
        // Stage 5: Security Scan
        // ==================================================

        stage('Security Scan with Trivy') {

            steps {

                script {

                    // Trivy Docker image vulnerabilities scan karega.
                    //
                    // Check karega:
                    //
                    // CVEs
                    // Critical Bugs
                    // Vulnerable Packages
                    //
                    // Security best practice.
                    trivy_scan()
                }
            }
        }


        // ==================================================
        // Stage 6: Push Docker Images
        // ==================================================

        stage('Push Docker Images') {

            parallel {

                // ----------------------------------
                // Push Main App Image
                // ----------------------------------

                stage('Push Main App Image') {

                    steps {

                        script {

                            docker_push(

                                imageName: env.DOCKER_IMAGE_NAME,

                                imageTag: env.DOCKER_IMAGE_TAG,

                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }


                // ----------------------------------
                // Push Migration Image
                // ----------------------------------

                stage('Push Migration Image') {

                    steps {

                        script {

                            docker_push(

                                imageName: env.DOCKER_MIGRATION_IMAGE_NAME,

                                imageTag: env.DOCKER_IMAGE_TAG,

                                credentials: 'docker-hub-credentials'
                            )
                        }
                    }
                }
            }
        }


        // ==================================================
        // Stage 7: Update Kubernetes Manifests
        // ==================================================

        stage('Update Kubernetes Manifests') {

            steps {

                script {

                    // Kubernetes deployment files update karega.
                    //
                    // Example:
                    //
                    // Old:
                    // image: easyshop-app:24
                    //
                    // New:
                    // image: easyshop-app:25
                    //
                    // Git repository me commit aur push bhi karega.
                    update_k8s_manifests(

                        imageTag: env.DOCKER_IMAGE_TAG,

                        manifestsPath: 'kubernetes',

                        gitCredentials: 'github-credentials',

                        gitUserName: 'Jenkins CI',

                        gitUserEmail: 'ashishkumardev53@gmail.com'
                    )
                }
            }
        }
    }
}

