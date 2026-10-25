# Night Owl Video

Original iPhone video-store game with paper-cutout customers. Requires iOS 16 or newer. No network, ads, or purchases. Progress saves locally.

## Play
Open the store at the counter. Pick the requested genre from Shelves, scan the VHS, take payment and count the exact change. Popcorn combos are included when requested. Reserve a title to set aside its next return. In Returns, scan each tape, review late/damage fees, rewind and shelve it. Collect held reservations from the return desk. The Store PC orders tapes, cleans spills, adds decoration and hires an assistant. Finish the queue and returns before closing the day; bills are paid and rentals return the next morning. Every third day is busier.

## Build and SideStore
The source is ready for a macOS/Xcode runner. Run the GitHub Actions **Build iPhone IPA** workflow, then download the **NightOwl-SideStore** artifact and extract `NightOwl.ipa`. Import that IPA into your configured SideStore installation so SideStore can sign it with your account. The build uses ad-hoc signing as an intermediate; it is not an App Store distribution build.

On a Mac with Xcode command-line tools: `bash scripts/build-ipa.sh`.

## Scope
This first playable version implements the rental/return management loop. It is a touch-based 2D game, with original titles and characters. It does not reproduce Retro Rewind's full 3D world, thousands of tapes, seasonal art, or every advanced feature. Reference task ideas: https://store.steampowered.com/app/3552140/Retro_Rewind_Video_Store_Simulator/
