library(reticulate)
library(birdnetR)
library(tidyverse)
library(tuneR)
library(seewave)

# install_birdnet() # only run once - it populates the venv with python packages etc 

# load and name the model engine

model <- birdnet_model_tflite() # gives a warning message Could not find Tensor RT, no idea of the significance of this.

# get a prediction for SL birds (I chose central SL coordinates around Makeni, not sure what radius is used)

meta_model <- birdnet_model_meta() 

sl_list <- predict_species_at_location_and_time(meta_model, latitude = 8.6, longitude = -12.0)

nrow(sl_list) # shows has 451 of the c580 SL regularly occurring species (excl vagrants) to train on

# Lines 21-38 mine! Overall to use purrr::pmap to iterate the model over a list of files within a directory and tabulate the results, then save the table

# get the species as a list

sl_birds <- as.list(sl_list$label)

# iterate over files

paths <- list.files("~/Music/phone-misc", full.names = TRUE)

arg <- list(audio_file = paths) 

p <- pmap(arg, predict_species_from_audio_file, model = model, filter = sl_birds, chunk_overlap_s = 0)
p
q <- bind_rows(p, .id = "group id")

q$end <- round(q$end, 1)
q$confidence <- round(q$confidence, 1)

paths

knitr::kable(q)

# join q and paths so each row has a column referencing the path of the audio file

# First some tidying to get the names and data types right (group_id vs "group id") and get both numeric so the table join works

paths_df <- as.data.frame(paths)
paths_df <- parsnip::add_rowindex(paths_df)
paths_df <- rename(paths_df, group_id = .row)

q <- q |>
    rename(group_id = "group id")

q$group_id <- as.numeric(q$group_id)

q_paths <- q |>
  left_join(paths_df)

q_paths
 # save
write_csv(q_paths, "q_paths.csv")
# or

saveRDS(q-paths, file = "q_paths.RData")

q_paths <- readRDS("q_paths.RData")


# Now we can find and look at any 3 sec segment quickly, e.g file four, chunk 6-9s had certaintly (confidence = 1) of Blue-breated Kingfisher

# all the file
file_4 <- readWave("/home/paul/Music/phone-misc/samaya_1.wav")
file_4
# the 6-9 seconds sample
file_4.6_9 <- readWave("/home/paul/Music/phone-misc/samaya_1.wav", from = 6, to = 9, units = "seconds")
file_4.6_9

savewav()


predictions <- predict_species_from_audio_file(model, "~/Music/birdnet_input/birdnet_mobile_ngsparrow.wav")

predictions <- predict_species_from_audio_file(model, "~/Music/birdnet_input/birdnet_mobile_ngsparrow.wav", chunk_overlap_s = 2, filter_species = sl_birds)

# pull out and save top predictions, rounded, as a df and view with

top_predictions <- as.data.frame(get_top_prediction(predictions))

top_predictions$confidence <- round(top_predictions$confidence, 1)

knitr::kable (top_predictions)


# repeat the model, filtered on SL birds

predictions_b <- predict_species_from_audio_file(model, "~/Music/birdnet_input/birdnet_mobile_ngsparrow.wav", filter_species = sl_birds)

# note Eurasian Tree Sparrow disappears from the predictions 

top_predictions_b <- as.data.frame(get_top_prediction(predictions_b))

top_predictions_b$confidence <- round(top_predictions_b$confidence, 1)

knitr::kable (top_predictions_b)

# save and reload RDS

saveRDS(sl_birds, file =  "sl_birds.RData")

sl_birds_b <- readRDS("sl_birds.RData")

glimpse(sl_birds_b)
