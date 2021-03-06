
library(babette)
testit::assert(is_beast2_installed())
testit::assert(mauricer::mrc_is_installed("NS"))

fasta_filename <- "my_alignment.fas"
testit::assert(file.exists(fasta_filename))

n_rows <- length(beautier:::create_site_models())
site_model_names <- rep(NA, n_rows)
clock_model_names <- rep(NA, n_rows)
tree_prior_names <- rep(NA, n_rows)
marg_log_liks <- rep(NA, n_rows)
marg_log_lik_sds <- rep(NA, n_rows)

tree_priors <- list(create_yule_tree_prior(), create_bd_tree_prior())

# Pick a site model
row_index <- 1
for (site_model in beautier:::create_site_models()) {
  for (clock_model in beautier:::create_clock_models()) {
    for (tree_prior in tree_priors) {
      marg_lik <- bbt_run(
        fasta_filenames = fasta_filename,
        site_models = site_model,
        clock_models = clock_model,
        tree_priors = tree_prior,
        mcmc = create_mcmc_nested_sampling(),
        beast2_path = get_default_beast2_bin_path()
      )$ns
      site_model_names[row_index] <- site_model$name
      clock_model_names[row_index] <- clock_model$name
      tree_prior_names[row_index] <- tree_prior$name
      marg_log_liks[row_index] <- marg_lik$marg_log_lik
      marg_log_lik_sds[row_index] <- marg_lik$marg_log_lik_sd
      row_index <- row_index + 1
    }
  }
}

df <- data.frame(
  site_model_name = site_model_names,
  clock_model_name = clock_model_names,
  tree_prior_name = tree_prior_names,
  marg_log_lik = marg_log_liks,
  marg_log_lik_sd = marg_log_lik_sds
)
knitr::kable(df)

best_row_index <- which(df$marg_log_lik == max(df$marg_log_lik))

df_best <- data.frame(
  site_model_name = site_model_names[best_row_index],
  clock_model_name = clock_model_names[best_row_index],
  tree_prior_name = tree_prior_names[best_row_index],
  marg_log_lik = marg_log_liks[best_row_index],
  marg_log_lik_sd = marg_log_lik_sds[best_row_index]
)
print("Best model:")
knitr::kable(df_best)
