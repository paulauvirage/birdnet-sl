library(reticulate)
library(birdnetR)
library(tidyverse)

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

paths <- list.files("~/Music/merlin_phone", full.names = TRUE)

arg <- list(audio_file = paths) 

p <- pmap(arg, predict_species_from_audio_file, model = model, filter = sl_birds, chunk_overlap_s = 2)
p
q <- bind_rows(p, .id = "group id")

q$end <- round(q$end, 1)
q$confidence <- round(q$confidence, 1)

knitr::kable(q)

saveRDS(q, file =  "merlin_phone_top_predictions.RData")

sl_birds_b <- readRDS("merlin_phone_top_predictiosn.RData")


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
