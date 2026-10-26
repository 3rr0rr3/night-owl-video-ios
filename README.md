# Night Owl Video

Original iPhone video-store game with paper-cutout customers. Requires iOS 16 or newer. No network, ads, or purchases. Progress saves locally.

## Play
Open the store at the counter. Pick the requested genre from Shelves, scan the VHS, take payment and count the exact change. Popcorn combos are included when requested. Reserve a title to set aside its next return. In Returns, scan each tape, review late/damage fees, rewind and shelve it. Collect held reservations from the return desk. The Store PC orders tapes, cleans spills, adds decoration and hires an assistant. Finish the queue and returns before closing the day; bills are paid and rentals return the next morning. Every third day is busier.

## Build and SideStore
The source is ready for a macOS/Xcode runner. Run the GitHub Actions **Build iPhone IPA** workflow, then download the **NightOwl-SideStore** artifact and extract `NightOwl.ipa`. Import that IPA into your configured SideStore installation so SideStore can sign it with your account. The build uses ad-hoc signing as an intermediate; it is not an App Store distribution build.

On a Mac with Xcode command-line tools: `bash scripts/build-ipa.sh`.

## Scope
This first playable version implements the rental/return management loop. It is a touch-based 2D game, with original titles and characters. It does not reproduce Retro Rewind's full 3D world, thousands of tapes, seasonal art, or every advanced feature. Reference task ideas: https://store.steampowered.com/app/3552140/Retro_Rewind_Video_Store_Simulator/

## Story & animation update (1.3)
There are now twelve adult regulars with stable portraits, jobs, film preferences and conversations. The Story tab follows seven playable chapters: inherit Aunt June's shop, reconnect the neighborhood, survive a rainy Friday, recover an old home movie, recruit a team, fund a projector and hold Maple Street movie night. Goals carry across days. Chapter rewards are paid once, the double-bill choice appears in the ending, and free play continues afterward. Existing shop saves are retained; campaign progress saves separately.

Characters blink, breathe and move their mouths when speaking. Customers enter and leave the queue with transitions, rental revenue floats above the shop, and the VHS deck spins while a tape rewinds over three seconds. Idle character motion pauses in the background and respects Reduce Motion. Open Story > Meet the 12 regulars to see the full cast.

The macOS workflow tests the complete campaign, dialogue accounting, one-time payments, legacy saves and asynchronous rewinding. The character-capture workflow produces both cast sheets, the opening story scene, an in-store screenshot and a short simulator video of the animations.

## Illustrated store restored (2.2)
The game uses the original 2D illustrated shop, adult paper-cutout customers and direct station tabs. The 3D renderer, movement controls and SceneKit dependency have been removed. Adult portrait proportions match the original art. Story chapters, character animations, rental tasks and existing saves remain.

The title screen keeps Start Game, Continue, New Game and How to Play. Menu saves and pauses the shift. Gameplay advances only while the store screen is active; app backgrounding saves progress. CI tests shop rules and story progression, builds the arm64 IPA, and captures the title and illustrated store in the iPhone simulator.
