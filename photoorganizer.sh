#!/bin/bash

DIR="${1}"

# Ensures a directory exists
function validate_subdirectory() {
  local path="${1}"
  local subdir="${2}"
  # Determine if directory exists and creates if it does not
  if [[ ! -d "${path}/${subdir}" ]]; then
    mkdir "${path}/${subdir}"
  fi
}

# Rename the image
function rename_image () {
  # Use the directory name as the base of the new image name
  image_full_new=$(echo "${image_dir}" | tr -d [:space:] | tr [:upper:] [:lower:])
  # Add the date/time, unique identifier, and extension to new image name
  image_full_new="${image_full_new}${image_datetime}-${image_id[0]}.${image_extension}"
  # Rename the image with the new image name
  mv "${image_path}/${image_full}" "${image_path}/${image_full_new}"
}

# Retrieve list of images in the directory and store in an array
for object in "${DIR}"/*; do
  if [[ -f "${object}" ]]; then
    images+=( "${object}" )
  fi
done

# Process each image
for image in "${images[@]}"; do

  # Determine a unique id to eliminate duplicates
  image_id=( $(md5sum "${image}") )

  # Determine file details
  image_path=$(dirname "${image}")
  image_dir=$(basename "${image_path}")
  image_full=$(basename "${image}")
  image_name="${image_full%.*}"
  image_extension="${image_full##*.}"
  image_datetime="$(stat -c %y "${image}"| cut -b 1-20 | \
    tr -d [:punct:] | tr -d [:space:])"
  image_year=${image_datetime:0:4}

  # Copy images to backup directory
  validate_subdirectory "${image_path}" "Backup"
  cp -p "${image_path}/${image_full}" "${image_path}/Backup/${image_full}"
  
  # Call function to rename the image
  rename_image

  # Moves images to year directory
  validate_subdirectory "${image_path}" "${image_year}"
  mv "${image_path}/${image_full_new}" "${image_path}/${image_year}/${image_full_new}"

done
