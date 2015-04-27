## variables
$opencv_version    = '3.0.0-beta'
$opencv_codebase   = "https://github.com/Itseez/opencv/archive/${opencv_version}.zip"
$opencv_directory  = '/home/vagrant'
$opencv_dependency = ['libopencv-dev', 'build-essential', 'cmake', 'git', 'libgtk2.0-dev', 'pkg-config', 'python-dev', 'python-numpy', 'libdc1394-22', 'libdc1394-22-dev', 'libjpeg-dev', 'libpng12-dev', 'libtiff4-dev', 'libjasper-dev', 'libavcodec-dev', 'libavformat-dev', 'libswscale-dev', 'libxine-dev', 'libgstreamer0.10-dev', 'libgstreamer-plugins-base0.10-dev', 'libv4l-dev', 'libtbb-dev', 'libqt4-dev', 'libfaac-dev', 'libmp3lame-dev', 'libopencore-amrnb-dev', 'libopencore-amrwb-dev', 'libtheora-dev', 'libvorbis-dev', 'libxvidcore-dev', 'x264', 'v4l-utils', 'unzip']

## define $PATH for all execs
Exec {path => ['/bin/', '/usr/bin/']}

## python-software-properties: installs the command 'add-apt-repository'.
#
#  @notify, send a 'refresh event' to 'enable-multiverse'.
package {'python-software-properties':
    ensure => present,
    notify => Exec['enable-multiverse'],
    before => Exec['enable-multiverse'],
}

## enable-multiverse: enables multiverse repository, therefore, allows
#                     installation of 'libfaac-dev'.
#
#  @refreshonly, when set to true, the corresponding exec will only run when
#      it receives an event. Refresh events can be sent via notify, subscribe,
#      or ~>.  In this case, 'python-software-properties' implements the needed
#      notify event.
exec {'enable-multiverse':
    command     => 'add-apt-repository multiverse',
    require     => Package['python-software-properties'],
    refreshonly => true,
    before      => Package[$opencv_dependency],
}

## opencv-dependency: install openv package dependencies.
#
#  @notify, send a 'refresh event' to 'wget-opencv'.
package {$opencv_dependency:
    ensure => present,
    notify => Exec['wget-opencv'],
    before => Exec['wget-opencv'],
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
#
#  @notify, send a 'refresh event' to 'move-opencv'.
exec {'unzip-opencv':
    command     => 'unzip opencv.zip -d opencv',
    cwd         => "${opencv_directory}",
    notify      => Exec['move-opencv'],
    refreshonly => true,
}

## move-opencv: move content of the opencv directory up one level.
#
#  @notify, send a 'refresh event' to 'remove-opencv-directory'.
exec {'move-opencv':
    command     => "mv ${opencv_directory}/opencv/opencv-${opencv_version}/* opencv",
    cwd         => "${opencv_directory}",
    refreshonly => true,
    notify      => Exec['remove-opencv-directory'],
}

## remove-opencv-directory: after the content of the opencv directory has
#                           been moved, remove the empty directory.
exec {'remove-opencv-directory':
    command     => "rm ${opencv_directory}/opencv/opencv-${opencv_version}"
    refreshonly => true,
    before      => File["${opencv_directory}/opencv/release"],
}

## directory-release: create 'release' directory.
#
#  @notify, send a 'refresh event' to 'cmake-CMakeLists'.
file {"${opencv_directory}/opencv/release":
    ensure => 'directory',
    notify => Exec['cmake-opencv'],
    before => Exec['cmake-opencv'],
}

## cmake-opencv: build opencv.
#
#  @notify, send a 'refresh event' to 'make-opencv'.
exec {'cmake-opencv':
    command     => 'cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local -D WITH_TBB=ON -D BUILD_NEW_PYTHON_SUPPORT=ON -D WITH_V4L=ON -D WITH_QT=ON -D WITH_OPENGL=ON ..',
    cwd         => "${opencv_directory}/opencv/release",
    notify      => Exec['make-opencv'],
    refreshonly => true,
}

## make-opencv: make opencv.
#
#  @notify, send a 'refresh event' to 'install-opencv'.
exec {'make-opencv':
    command     => "make -j $(nproc)",
    cwd         => "${opencv_directory}/opencv/release",
    timeout     => 1800,
    notify      => Exec['install-opencv'],
    refreshonly => true,
}

## install-opencv: install opencv.
exec {'install-opencv':
    command     => 'make install',
    cwd         => "${opencv_directory}/opencv/release",
    notify      => Exec['update-opencv'],
    refreshonly => true,
}

## update-opencv: execute bash as root, and overwrite '.conf' file with echo.
#                 This will define the settings required for a 'dynamic linker'.
exec {'update-opencv':
    command => "/bin/bash -c 'echo \"/usr/local/lib\" > /etc/ld.so.conf.d/opencv.conf",
    notify  => Exec['ldconfig'],
    refreshonly => true,
}

## ldconfig: scan current running system, set up the symbolic links (i.e. dynamic
#            linkers), and cache needed (for dynamic linkers) to load shared
#            libraries. This will allow the opencv library to run properly.
exec {'ldconfig':
    command     => 'ldconfig',
    refreshonly => true,
}
