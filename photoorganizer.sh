#!/bin/bash

set -x

ORGANIZE="${1}"
LOGS_DIR="${2}"
LOG_FILE="${LOGS_DIR}/$(date +%Y%m%d%H%M%S).txt"
DIR="${3}"

# Write message to a log file
function logger() {
  local message="${1}"
  echo "$(date +%H%M%S) - ${message}" >> "${LOG_FILE}"
}

# Exits the script when an error is encountered
function error() {
  local message="${1}"
  logger "${message}"
  logger "The process was aborted."
  exit 1
}

# Validate directory
function validate_directory () {
  local directory="${1}"
  if [[ -f "${directory}" ]]; then
    error "${directory} is exists as a file."
  fi
  if [[ -d "${directory}" ]]; then
    logger "The ${directory} directory exists."
  else
    create_directory "${directory}"
  fi
}

# Create directory
function create_directory() {
  local directory="${1}"
  if ! mkdir "${directory}"; then
    error "The ${directory} was not created."
  fi
  logger "The ${directory} directory was created."
}

# Determine new file name and rename the image files accordingly
function rename_image() {
  image_datetime=$(exiftool -T -CreateDate "${image_path}" | tr -d "[:punct:]" | tr -d "[:space:]")
  if [[ -z "${image_datetime}" ]]; then
    image_increment=$(( ${image_increment} + 1 ))
    image_number=$(( 19700101000000 + ${image_increment} ))  # TODO: Come up with a better solution
    image_rename_basename="${image_number}-${image_id[0]}.${image_extension}"
  else
    image_rename_basename="${image_datetime}-${image_id[0]}.${image_extension}"
  fi
  image_rename_path="${image_dirpath}/${image_rename_basename}"
  mv "${image_path}" "${image_rename_path}"
  logger "The ${image_basename} image file was renamed to ${image_rename_basename}."
}

# Organize image files by year
function organize_image() {
  image_year=${image_rename_basename:0:4}
  image_organize_dirpath="${image_dirpath}/${image_year}"
  validate_directory "${image_organize_dirpath}"
  image_organize_path="${image_organize_dirpath}/${image_rename_basename}"
  mv "${image_rename_path}" "${image_organize_path}"
  logger "The ${image_rename_basename} image file was moved to the ${image_year} directory."
}

# Call function to ensure Logs subdirectory exists and create it if not
validate_directory "${LOGS_DIR}"

# Retrieve and store initial list of image file in the directory
for object in "${DIR}"/*; do
  if [[ -f "${object}" ]]; then
    images+=( "${object}" )
  fi
done
logger "There were ${#images[@]} image files in the ${DIR} directory."

# Gather details of and process each image file
for image in "${images[@]}"; do

  # Determine image file id, path, name, and extension information
  image_id=( $(md5sum "${image}") )            # ca598ba1cb1a18d3db662d2b9922425d  /home/codygriffin/Pictures/Steve/stevewalk.jpg
  image_path="${image}"                        # /home/codygriffin/Pictures/Steve/stevewalk.jpg
  image_dirpath=$(dirname "${image_path}")     # /home/codygriffin/Pictures/Steve
  image_dirname=$(basename "${image_dirpath}") # Steve
  image_basename=$(basename "${image_path}")   # stevewalk.jpg
  image_name="${image_basename%.*}"            # stevewalk
  image_extension="${image_basename##*.}"      # jpg

  # Identify and remove duplicate image files while continuing to process remaining files
  image_id_regex="\<${image_id[0]}\>"
  if [[ ${unique_image_ids[*]} =~ ${image_id_regex} ]]; then
    duplicate_image_ids+=( "${image_id[0]}" )
    # Duplicate image files are deleted
    rm "${image_path}"
    logger "The ${image_basename} image file was identified as a duplicate and deleted."
    # No further processing of duplicate image files occurs
    continue
  else
    unique_image_ids+=( "${image_id[0]}" )
    # Unique image files continue to be processed
    rename_image
    if [[ ${ORGANIZE} == "true" ]]; then
      organize_image
    fi
  fi

done

logger "There were ${#duplicate_image_ids[@]} duplicate image files deleted."
logger "There were ${#unique_image_ids[@]} unique image files."
