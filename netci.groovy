import jobs.generation.Utilities

def project = GithubProject
def branch = GithubBranchName
def isPR = true
def platformList = ['Ubuntu16.04:Debian', 'Windows_2016:WindowsServerCore', 'Windows Nano 2016:NanoServer']

platformList.each { platform ->
    def(hostOS, containerOS) = platform.tokenize(':')
    def newJobName = Utilities.getFullJobName(project, containerOS, isPR)
    def machineLabel = 'latest-or-auto-docker'

    def newJob = job(newJobName) {
        steps {
            if (hostOS == 'Windows_2016')
            {
                batchFile("powershell -NoProfile -Command .\\build-and-test.ps1")
            }
            else if (hostOS == 'Windows Nano 2016')
            {
                batchFile("powershell -NoProfile -Command .\\build-and-test.ps1 -OS nanoserver")
                machineLabel = ''
            }
            else
            {
                shell("./build-and-test.sh")
            }
        }
    }

    Utilities.setMachineAffinity(newJob, hostOS, machineLabel)
    Utilities.standardJobSetup(newJob, project, isPR, "*/${branch}")
    Utilities.addGithubPRTriggerForBranch(newJob, branch, containerOS)
}
