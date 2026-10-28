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

## Friendly shop update (2.3)
New shops have a five-step first-customer guide with the clock paused and one visitor at a time. Skip is always available. Existing saves bypass onboarding. A contextual next-task card jumps to the right station, matching genres are highlighted, and station badges show waiting customers, returns/holds, ready story rewards and cleaning tasks.

Play Options on the title screen and Store PC offers half-speed Relaxed mode and independent automatic change counting. Rentals still require confirmation. Options persist between sessions and new games.

Closing a day opens a saved report with rentals/fees, story rewards, purchases, bills, net profit, emergency support, processed tapes and tomorrow's goals. Store PC can reopen the last report. New daily accounting begins when updating to this release; previous transaction history is not reconstructed.

Customize your shop in Store PC: nine poster, shelf and counter styles unlock through rental milestones. Purchases cost shop currency once; owned styles switch freely and change the illustration. No purchases use real money. New Game resets cosmetics and shop progress while retaining play options.

## Scanner & register animation (2.4)
Successful rental and return scans show a VHS barcode, a sweeping red scanner beam and an accepted checkmark. Taking payment opens the illustrated cash drawer and slides in a $10 note. Completed rentals send out change coins and print a receipt; collected return fees also animate the register. Feedback floats above the current screen so it remains visible while scrolling and does not block buttons.

Reduce Motion uses a static success card. Animation timers expire after backgrounding, and effects are not saved or replayed by Continue. Repeated scans/payments, rejected change and already-collected fees do not retrigger success effects. Tests cover event amounts, action guards and save safety.

## Neighborhood expansion (2.5)
All six VHS films now have original procedural cover illustrations, titles, taglines, collector borders and mini covers in the store shelves. Customer mood requests have genre hints and an optional direct-request toggle.

Chat once per regular per day and complete rentals to grow friendships. Three friendship points earns a rare tape gift; the collection also grows through a daily donation box, stock trades (10 reputation) and bonus deliveries (25 reputation, every third order). Four rotating daily events spotlight genres and reward completed rental goals once per day. Reputation increases with successful rentals, case repairs and events, attracting more visitors.

Store PC opens Events, friends & rare tapes, and Hands-on chores. Wipe all six patches to clean a spill, drag a fully processed returned VHS onto its shelf, and press three repair points after inspecting a damaged case. Tap controls remain available for cleaning and shelving. Repairs never undo collected fees.

Play Options includes scanner/register/rewind sounds and an optional original eight-second retro music loop with rain texture on rainy days. Audio is synthesized locally, mixes with other audio, respects silent mode and stops in the background. Music starts disabled.

The title screen has three independent save slots. The existing shop migrates into slot 1 on its next save. Switching writes the current shop first; New Game resets only the selected slot. Shop, story, preferences, friendships and collectibles are isolated per slot. Empty slots begin with fresh shop progress.

## Bigger library and shop tools (2.6)
The catalog expands to 30 original films with two mood tags and a synopsis each. Legacy stock and IDs are preserved. Cover art extends the six illustrated genre families with distinct titles, colors and star patterns. Film Browser searches titles, synopses and mood tags, filters genre/mood/in-stock copies, and handles ordering as well as recommendations.

Store PC contains a customer notebook (last ten rentals per regular, favorites, friendship and current requests), four functional equipment upgrades, and optional daily surprises. A fast rewinder takes one second; a larger return bin carries up to four returns between days; a second waiting desk allows seven queued customers; wholesale ordering reduces copy costs to $10. Surprises provide clue-based missing-film/case tasks or free stock, with one reward per day. They can be disabled and never appear in Relaxed mode. Tap the illustrated shelves, return sign or register to change stations.

Play Options adds larger text, independent effect/music volumes and optional haptics. Export/import in Store PC uses JSON files compatible with Files/AirDrop. Imported backups are validated before a confirmation, replace only the active slot, and retain a local pre-import copy that can be restored. Old six-film backups and existing save slots migrate automatically. Backups contain only game data.

## Visible shopkeeper and counter scenes (2.7)
The rental counter now keeps an adult shopkeeper marked YOU and the customer visible in a stationary counter scene above the scrolling controls. VHS scans move the tape over a physical scanner, payment travels from the customer to the cash drawer, and sales hand over the tape/change while a narrow receipt feeds from the register. The served customer and movie stay attached to the transaction until its animation finishes, even after the queue advances. The return desk uses the same shopkeeper scene.

Floating scan/payment/receipt cards have been removed from the game. Reduce Motion uses static transaction poses and feedback. The counter stays visible while choosing scan/payment/change actions below it. Existing sound/haptic preferences and all save data remain.

## Personalized shopkeeper portrait (2.8)
The playable shopkeeper now has a dedicated illustrated portrait with swept dark hair, close-cropped sides, black rectangular glasses, a short full beard and a blue crew-neck T-shirt. The scan animation shares its shirt and skin palette. Customer portraits remain separate. The character retains blinking, gentle breathing and Reduce Motion behavior. The capture workflow includes a full-size portrait preview.

## Walking customers (2.9)
The counter has a visible foreground walkway. Customers enter from the exit-side aisle, walk to the service spot with alternating legs and a walking bob, and pause for the transaction. Checkout keeps the served visitor visible for the handover, then they walk out carrying their VHS. The next visitor approaches only after the previous customer leaves. Counter actions pause during movement; other station tabs remain usable.

The shopkeeper keeps the personalized portrait. Arrival is remembered across station changes so choosing a film does not replay the same customer's entrance. Reduce Motion swaps poses immediately. Movement is presentation-only and is never saved; imports and slot switches clear transient movement. Tests check lane endpoints, direction, clamping, handoff position and visitor identity. The simulator video captures a delayed arrival, full rental, departure and next-customer approach.

## App icon and back-stock pickup (3.0)
Night Owl has an original opaque mint/gold VHS-owl icon with a crescent moon and stars. The standard-library icon generator produces iPhone/iPad sizes and a 1024px marketing icon. Xcode actool compiles the asset catalog and merges its icon metadata into the IPA and simulator bundles.

Choosing a film queues a visible shopkeeper pickup: walk back to the stock shelf, take the selected tape and walk to the counter carrying its cover. The tape rests on the scanner afterward. Counter actions pause until retrieval completes, and Reduce Motion immediately readies the tape. Unscanned selections restore a pending pickup after loading a save; scan/payment/rental state and stock accounting remain unchanged. Pickup motion and pending state are presentation-only and do not spend or duplicate stock.

## Version 3.1 — a living video store

Adds shelf browsing with cover inspection, conversation gestures, relaxed waiting/watch gestures, connected tape handoffs, return-bin drops and rewind completion, clerk restocking, fan/CRT/neon/rain ambience, opening and closing shutters, customer reactions, and friendship/rare-tape celebrations. All movement respects Reduce Motion and pauses in the background. Waiting is cosmetic and does not reduce patience or impose a penalty. Presentation events expire independently of saves, stock and payments; a newer cue cannot be cleared by an older timer.

## Version 3.2 — connected customer gestures

Replaces floating sleeve overlays with articulated arms drawn inside each customer canvas. Gestures replace the original arm and use the actual shirt and skin colors. Waiting watch stays on the wrist, departure waves stay attached while walking, and carried VHS cases sit beside the other hand. Keeps customer names visible while waiting.

## Version 4.0 — build your neighborhood shop

Town adds a persistent nine-square floor plan (tap to swap four fixtures), staff assignments, one weekly income/friendship/collection project, inspected used-tape negotiations, after-hours double bills with regular reactions, four seven-day seasons and a newspaper reflecting completed activities. Staff restocking only shelves fully processed returns; used-tape buys add exactly one copy. Weekly and seasonal rewards, daily trades and screenings have repeat guards.

The checkout groups the customer, selected film, total, change and one primary next-step button. Manual change remains available. Film credits and runtimes support mood/actor/short-film requests with several valid answers and extra friendship for a thoughtful match. The tutorial still uses exact genres. Forecasts highlight seasonal/event demand and low stock before opening.

Existing saves and older exported backups load with default expansion state. New exports, save slots and imports carry the expansion; imports validate its layout, film IDs, staff jobs, goals and offer bounds. New Game resets only the active shop. Town activities use shop currency and fictional films/credits.

## Version 4.1 — easier navigation and desk tasks

A permanent Counter / Returns / Films / More bottom bar replaces the buried station grid. A compact day/time/cash header stays visible, and desk scenes can be hidden for more control space. More links to shop management, Town, Story and the customer notebook. Shop management separates Daily, Stock, Style and Settings; closing the day explains pending work and confirms the bill/advance action.

Returns presents one next-step button and four progress indicators. Film browsing starts with matching choices, offers clear/reset controls and puts the browsing animation in an optional disclosure. Checkout adds a one-dollar subtraction control and explains missing/excess change before enabling the final rental. New feedback expands on tap. Large text, Reduce Motion, original character art and save formats are retained.
