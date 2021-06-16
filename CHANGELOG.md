# Changelog

## 0.5.1

- Add file existence checks to `Direnv` and `Homebrew`.

## 0.5.0

- [breaking change] Medic looks for files at:
  
  * `.medic/doctor.exs`
  * `.medic/update.exs`
  
  See docs at https://hexdocs.pm/medic/Medic.Update.html

## 0.4.0

- [breaking change] `Medic.Update` now requires `.medic.update.exs` config file.
  See docs at https://hexdocs.pm/medic/Medic.Update.html

## 0.3.0

- Skip checks by creating files at `.medic/skipped`

## 0.2.0

- Load local checks from `.medic/checks`

## 0.1.0

- Initial release
