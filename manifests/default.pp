## variables
$opencv_codebase   = 'https://github.com/Itseez/opencv/archive/3.0.0-beta.zip'
$opencv_directory  = '/home/vagrant'
$opencv_dependency = ['libopencv-dev', 'build-essential', 'checkinstall', 'cmake', 'pkg-config', 'yasm', 'libtiff4-dev', 'libjpeg-dev', 'libjasper-dev', 'libavcodec-dev', 'libavformat-dev', 'libswscale-dev', 'libdc1394-22-dev', 'libxine-dev', 'libgstreamer0.10-dev', 'libgstreamer-plugins-base0.10-dev', 'libv4l-dev', 'python-dev', 'python-numpy', 'libtbb-dev', 'libqt4-dev', 'libgtk2.0-dev', 'libfaac-dev', 'libmp3lame-dev', 'libopencore-amrnb-dev', 'libopencore-amrwb-dev', 'libtheora-dev', 'libvorbis-dev', 'libxvidcore-dev', 'x264', 'v4l-utils', 'unzip']

## define $PATH for all execs
Exec {path => ['/usr/bin/']}

## python-software-properties: installs the command 'add-apt-repository'.
#
#  @notify, send a 'refresh event' to 'enable-multiverse'.
package {'python-software-properties':
    ensure => present,
    notify => Exec['enable-multiverse'],
}

## enable-multiverse: enables multiverse repository, therefore, allows
#                     installation of 'libfaac-dev'.
#  @refreshonly, when set to true, the corresponding exec will only run when
#      it receives an event. Refresh events can be sent via notify, subscribe,
#      or ~>.  In this case, 'python-software-properties' implements the needed
#      notify event.
exec {'enable-multiverse':
    command => 'add-apt-repository multiverse',
    require => Package['python-software-properties'],
    refreshonly => true,
}

## opencv-dependencies
#
#  @notify, send a 'refresh event' to 'wget-opencv'.
package {$opencv_dependency:
    ensure => present,
    notify => Exec['wget-opencv'],
}

## wget-opencv: install opencv from github repository. The command will only
#               execute if the current file is older, or doesn't yet exist.
#
#  @require, defines depedencies for given command.
#
#  @cwd, change the current working directory.
#
#  @path, the qualified path for the supplied command.
#
#  @timeout, the maximum time (seconds) the supplied command is allowed to
#      run. By default, this attribute is set to 300.
#
#  @notify, send a 'refresh event' to 'unzip-opencv'.
exec {'wget-opencv':
    command     => "wget -N ${opencv_codebase} -O opencv.zip",
    cwd         => "${opencv_directory}",
    timeout     => 400,
    notify      => Exec['unzip-opencv'],
    refreshonly => true,
}

## unzip-opencv: unzip the installed opencv.
exec {'unzip-opencv':
    command     => 'unzip opencv.zip',
    cwd         => "${opencv_directory}",
    refreshonly => true,
    before      => File["${opencv_directory}/opencv/release"],
}

## directory: create 'release' directory
#
#  @notify, send a 'refresh event' to 'cmake-opencv'.
file {"${opencv_directory}/opencv/release":
    ensure => 'directory',
    notify => Exec['cmake-opencv'],
}

## cmake-opencv: build opencv
#
#  @notify, send a 'refresh event' to 'make-opencv'.
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
