# Vision Components MIPI CSI-2 driver for Toradex Verdin i.MX8M Plus
![VC MIPI camera](https://www.vision-components.com/fileadmin/external/documentation/hardware/VC_MIPI_Camera_Module/VC_MIPI_Camera_Module_Hardware_Operating_Manual-Dateien/mipi_sensor_front_back.png)

## Version 0.1.0
* Supported boards
  * Toradex Dahlia Carrier Board V1.0C
* Supported cameras 
  * VC MIPI IMX327C
  * VC MIPI IMX296 / VC MIPI IMX296C
* Linux kernel 
  * Version 5.4.115
* Features
  * Image Streaming in Y10 and SBGGB10 format (pixel values are left aligned).
  * Exposure and Gain can be set via V4L2 library.
  * vcmipidemo supports software implementation to correct the left alignment by a 6 bit right shift.
* Known Issues
  * The first 4x2 pixels show fixed pixel values

## Prerequisites for cross-compiling
### Host PC
* Recommended OS is Ubuntu 18.04 LTS
* You need git to clone this repository
* All other packages are installed by the scripts contained in this repository

# Installation
When we use the **$** sign it is meant that the command is executed on the host PC. A **#** sign indicates the promt from the target so the execution on the target. In our case the Ixora Apalis board.

1. Create a directory and clone the repository   
   ```
     $ cd <working_dir>
     $ git clone https://github.com/pmliquify/vc_mipi_imx8mp
   ```

2. Setup the toolchain and the kernel sources. The script will additionaly install some necessary packages like *build-essential* or *device-tree-compiler*.
   ```
     $ cd vc_mipi_imx8mp/bin
     $ ./setup.sh --host
   ```
   As default the driver for the imx296 / imx296C is activated. If you want to use the imx327C sensor you have to patch the device tree.
   ```
     $ ./setup.sh --imx327
   ```
   To switch back to the imx296 driver type
   ```
     $ ./setup.sh --imx296
   ```

3. Build (all) the kernel image, kernel modules and device tree files.
   ```
     $ ./build.sh --all
   ```

4. Create a new Toradex Easy Installer Image. Insert a USB stick (FAT formated) with minimum 1GB capacity. The script will download the reference image from toradex patch it with the build kernel and device tree files from step 3 and copy the image to the usb stick.
   ```
     $ ./create_tezi.sh -m /media/<username>/<usb-stick-name>
   ```

5. Enter recovery mode by following the [imx-recovery-mode](https://developer.toradex.com/knowledge-base/imx-recovery-mode) instructions.   
We provide a script to easily flash an image. It will download the tools from toradex and start to watch for a matching usb device to flash to.
   ```
     $ ./recover.sh
   ```

6. Plugin the USB stick and install the prepared image.

7. After boot up, install the kernel modules we have build in step 3.
   ```
     $ ./flash.sh --modules
   ```

# Testing the camera
The system should start properly and the Qt Cinematic Demo should be seen on the screen.   

1. First install the test tools to the target.
   ```
     $ ./build.sh --test
     $ ./flash.sh --test
   ```

2. On the target switch to a console terminal by pressing Ctrl+Alt+F1

3. Login and check if the driver was loaded properly. You should see something like this in the second box.
   ```
     apalis-imx8 login: root
     # dmesg | grep imx290
   ```
   ```
         5.827769] imx290 2-001a: chip ID 0xffd0
   ```

4. Start image aquisition by executing following command. The folder *test* was installed by the script in step 1.   
   **Please note the option -afx4 to suppress ASCII output, output the image to the framebuffer, output image informations and apply the 4 bit shift correction**
   ```
     # ./test/imx327.sh -x 1000 -g 10
     Suppressing ASCII capture at stdout.
     Activating /dev/fb0 framebuffer output.
     Printing image info for every acquired image.
     Image raw data will be shifted 6 bits right.
     Applying white balance values: 120 185 165
     Setting Shutter Value to 1000.
     Setting Gain Value to 10.000000.
     [ 1183.681195] bypass csc
     [ 1183.683607] input fmt RGB4
     [ 1183.686337] output fmt RG10
     img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - c0ff 80ff 80ff c0ff 8014 8017 c013 0019 0015 0018 
     img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - 00ff c0ff 40ff 40ff c014 4019 4014 8018 4014 c018 
     img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - 00ff c0ff c0ff c0ff 4015 0019 0014 8018 0014 0018 
     img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - 00ff c0ff 40ff 40ff 8014 8018 c014 8018 4014 c018 
     img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - c0ff 80ff c0ff 80ff 4014 0018 c013 8018 8014 0018 
     img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - c0ff 40ff c0ff 80ff 8014 0019 4015 4018 8014 4019
     ...
   ```

5. The image information output shows the first 20 byte of the image raw data. In your application you have to correct the left alignment of the pixel values by a 6 bit right shift while debayering the raw image data.
   ```
                                                           R    G    R    G    ...
    img.org (fmt: RG10, dx: 1920, dy: 1080, pitch: 3840) - c0ff 80ff 80ff c0ff 8014 8017 c013 0019 0015 0018 
                                                             ^    ^    ^    ^  ...
                                                           This are the MSBs (most significant bits)
                                                           A color component is represented as little endian
                                                  
                                                           ff03 fe03 fe03 ff03 5200 5e00 4f00 6400 0054 0060
                                   >> 6 bit right shifted     ^    ^    ^    ^    ^    ^    ^    ^    ^    ^
                                               big endian  03ff 03fe 03fe 03ff 0052 005e 004f 0064 5400 6000
                                                  decimal  1023 1022 1022 1023   82   94   79  100   84   96
                                                           ^-----------------^
                                                            fixed pixel values
   ```
