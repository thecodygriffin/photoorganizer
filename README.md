# Description
A bash shell script that identifies duplicates, renames, and organizes images in a directory by year.

# Input Parameters
The script was written to require the 3 following input parameters so the same script can be used with multiple folders:
1. whether the images should be organized into subdirectories by year or not
2. location of the logs directory
3. location of the images directory

The are 2 options for whether the images should be organized into subdirectories by year or not: true and false.

The following example command assumes these input parameter values:
1. the images are to be organized into subdirectories by year with "true"
2. the logs directory is located at "/mnt/Storage/Logs/photoorganizer/Steve"
3. the images directory is located at "mnt/Home/Pictures/Animals/Steve"

`./photoorganizer.sh "true" "/mnt/Storage/Logs/photoorganizer/Steve" "/mnt/Home/Pictures/Animals/Steve"`

# Features
* Validates directories
* Retrieves list of images in directory
* Determines unique value of each image using md5sum and deletes duplicates
* Renames images to contain exif create date timestamp, if it exists
* Organizes the images into year subdirectories, if desired
