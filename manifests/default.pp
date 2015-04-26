## variables
$opencv_directory  = '/home/vagrant'
$opencv_dependency = ['libopencv-dev', 'build-essential', 'checkinstall', 'cmake', 'pkg-config', 'yasm', 'libtiff4-dev', 'libjpeg-dev', 'libjasper-dev', 'libavcodec-dev', 'libavformat-dev', 'libswscale-dev', 'libdc1394-22-dev', 'libxine-dev', 'libgstreamer0.10-dev', 'libgstreamer-plugins-base0.10-dev', 'libv4l-dev', 'python-dev', 'python-numpy', 'libtbb-dev', 'libqt4-dev', 'libgtk2.0-dev', 'libfaac-dev', 'libmp3lame-dev', 'libopencore-amrnb-dev', 'libopencore-amrwb-dev', 'libtheora-dev', 'libvorbis-dev', 'libxvidcore-dev', 'x264', 'v4l-utils']

## define $PATH for all execs
Exec {path => ['/usr/bin/']}

## python-software-properties: installs the command 'add-apt-repository'.
package {'python-software-properties':
    ensure => present,
}

## enable-multiverse: enables multiverse repository, therefore, allows
#                     installation of 'libfaac-dev'.
exec {'enable-multiverse':
    command => 'add-apt-repository multiverse',
    require => Package['python-software-properites'],
}

## git: install git if not 'present'.
package {'git':
    ensure => present,
}

## opencv-dependencies
package {$opencv_dependency:
    ensure => present,
}

## git-opencv: install opencv from github repository. However, if the target
#              clone path already exists, then successive 'git clone'
#              commands will not succeed.
#
#  @require, defines depedencies for given command.
#
#  @cwd, change the current working directory.
#
#  @path, the qualified path for the supplied command.
#
#  @timeout, the maximum time (seconds) the supplied command is allowed to
#      run. By default, this attribute is set to 300.
exec {'git-opencv':
    command => 'git clone https://github.com/Itseez/opencv.git opencv/',
    require => Package['git'],
    cwd     => "${opencv_directory}",
    timeout => 1450,
}

## directory: create 'release' directory
#
#  @notify, sends a 'refresh event' to 'cmake-opencv'.
file {"${opencv_directory}/opencv/release":
    ensure => 'directory',
    notify => Exec['cmake-opencv'],
}

## cmake-opencv: build opencv
#
#  @refreshonly, when set to true, the corresponding exec will only run when
#      it receives an event. Refresh events can be sent via notify, subscribe,
#      or ~>.  In this case, 'git-opencv' implements the needed notify event.
exec {'cmake-opencv':
    command     => 'cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D INSTALL_C_EXAMPLES=ON -D INSTALL_PYTHON_EXAMPLES=ON -D BUILD_EXAMPLES=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..',
    cwd         => "${opencv_directory}/opencv/release",
    refreshonly => true,
    notify      => Exec['make-opencv'],
}

## make-opencv: make opencv
#
#  @refreshonly, listens to the notify event from 'cmake-opencv'.
exec {'make-opencv':
    command     => 'make',
    cwd         => "${opencv_directory}/opencv/release",
    refreshonly => true,
    notify      => Exec['install-opencv'],
}

## install-opencv: install opencv
#
#  @refreshonly, listens to the notify event from 'make-opencv'.
exec {'install-opencv':
    command    => 'make install',
    cwd         => "${opencv_directory}/opencv/release",
    refreshonly => true,
}
