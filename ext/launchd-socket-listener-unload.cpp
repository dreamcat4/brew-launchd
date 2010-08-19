// 
// launchd-socket-listener-unload.cpp
// http://fazekasmiklos.blogspot.com/2007/04/howto-unload-launchd-deamon-from-itself.html
// 
// Instructions by Dreamcat4 (dreamcat4@gmail.com)
// 
// To compile:
// $ g++ launchd-socket-listener-unload.cpp -o launchd-socket-listener-unload
// 
// A small program which unloads the launchd job that started it
// Use with the below configuration to trigger the real job to load
// 
// Create a plist file for this daemon called "launchd.myjob.label-loader.plist"
// Put the listener socket definitions here
// 
// 
// <key>Program</key>
// <string>/path/to/launchd-socket-listener-unload</string>
// <key>ServiceIPC</key>
// <true/>
// <key>Sockets</key>
// <dict>
//     <key>Listeners</key>
//     <dict>
//         <!-- Service name (/etc/services), or a tcp port number -->
//         <!-- or can be anything else launchd supports (udp,etc) -->
//         <key>SockServiceName</key>
//         <string>8080</string>
//     </dict>
// </dict>
// 
// You probably already have made a 2nd plist file called "launchd_myjob_label.plist"
// Add to this file a KeepAlive directive, which depends on the first job not running
// 
// keep alive -> other job enabled -> false
// 
// <key>KeepAlive</key>
// <dict>
//     <key>OtherJobEnabled</key>
//     <dict>
//         <key>launchd.myjob.label-loader</key>
//         <false/>
//     </dict>
// </dict>
// 
// 
// This job will then start when the first job is unloaded, which is
// whenever the first job is triggered by one of the listener sockets
// 
// Bear in mind, 
// The very first http request / connection attempt will be dropped
// So a connecting client will have to try again in order to establish
// a connection to the real job.

#include <stdlib.h>
#include <errno.h>
#include <syslog.h>

#include "launch.h"

class LaunchD
{
public:
 LaunchD()
 {
  startedWithLaunchD = false;
  me = 0;
  CheckIn();
 }

 ~LaunchD()
 {
  if (me) {
   launch_data_free(me);
  }
 }

 bool CheckIn(bool allowRunWithoutLaunchd = true)
 {
  launch_data_t msg, resp;
  msg = launch_data_new_string(LAUNCH_KEY_CHECKIN);
  if ((resp = launch_msg(msg)) == NULL) {
   if (allowRunWithoutLaunchd) {
    startedWithLaunchD = false;
    return false;
   }
   syslog(LOG_ERR,"Checkin with launchd failed: %m");
   exit(EXIT_FAILURE);
  }
  launch_data_free(msg);
  if (LAUNCH_DATA_ERRNO == launch_data_get_type(resp)) { 
   errno = launch_data_get_errno(resp); 
   if (errno == EACCES) { 
    syslog(LOG_ERR, "Check-in failed. Did you forget to set" 
        "ServiceIPC == true in your plist?"); 
   } else { 
    syslog(LOG_ERR, "Check-in failed: %m"); 
   } 
   exit(EXIT_FAILURE); 
  }
  launch_data_t tmp = launch_data_dict_lookup(resp, LAUNCH_JOBKEY_LABEL); 
  me = launch_data_copy(tmp);
  if(me)
  {
      syslog(LOG_ERR, "%s triggered\n",job_label()); 
  }
  startedWithLaunchD = true;
  return true;
 }
 
 const char* job_label()
 {
     return launch_data_get_string(me);
 }

 bool Stop()
 {
  if (startedWithLaunchD) {
   launch_data_t resp;
   launch_data_t msg = launch_data_alloc(LAUNCH_DATA_DICTIONARY);
   if (! launch_data_dict_insert(msg,me,LAUNCH_KEY_REMOVEJOB)) {
    syslog(LOG_ERR, "launch_data_dict_insert failed!\n"); 
    return false;
   }
   if (! launch_data_dict_insert(msg,me,LAUNCH_KEY_STOPJOB)) {
    syslog(LOG_ERR, "launch_data_dict_insert failed!\n"); 
    return false;
   }
   syslog(LOG_ERR, "%s unloaded\n", job_label()); 
   resp = launch_msg(msg);
   syslog(LOG_ERR, "%s ...not unloaded. Failure when trying to unload %s.\n", job_label(), job_label()); 
   if (resp == NULL) {
    syslog(LOG_ERR, "launch_msg() LAUNCH_KEY_STOPJOB failed!\n"); 
    return false;
   }
   if (LAUNCH_DATA_ERRNO == launch_data_get_type(resp)) { 
    errno = launch_data_get_errno(resp); 
    if (errno == EACCES) { 
     syslog(LOG_ERR, "Stop request failed EACCESS!"); 
    } else { 
     syslog(LOG_ERR, "Check-in failed: %m"); 
    } 
    exit(EXIT_FAILURE);
   }
   launch_data_free(msg);
  }
  return true;
 }
private:
 bool   startedWithLaunchD;
 launch_data_t me;
};


int main()
{
    LaunchD ld;
    ld.Stop(); 
}

