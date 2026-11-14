# Demo video script (target 8 minutes)

Record the emulator window plus your voice. Prepare BEFORE recording:
- Two accounts already created: `student@…` (role student) and `staff@…`
  (role changed to `staff` in the Firestore console).
- One or two older reports already in Firestore so lists are not empty.
- A photo in the emulator gallery (drag an image onto the emulator window).
- Emulator at 100 % scale, notifications off, Firestore console open in a
  second browser tab (for the rules / data structure shot).

Timings are cumulative. Keep each step short; the graders tick boxes for
authentication, submitting, browsing/filtering, and a staff status update.

---

## 0:00 – 0:40  Intro (face cam optional, or app on splash)
"Hi, I'm Kamy Uwambaye. This is my Campus Incident Reporter, built with
Flutter, Riverpod for state management, and Firebase Authentication,
Cloud Firestore and Firebase Storage. Students report campus issues and
track them; authorised staff review and update them. I'll show sign-up and
sign-in, submitting a report with a photo, browsing and filtering, and a
staff account updating a report's status in real time."

## 0:40 – 1:40  Authentication
1. Launch the app → login screen.
2. Tap *Create one*. Tap *Create Account* with empty fields → show the
   inline validation messages. Type a bad email and a 3-character password →
   show those errors too.
   "Validation runs client-side with reusable validators, and the same
   limits are enforced again in the Firestore security rules."
3. Fill in a new student (name, email, department, password) → account is
   created, app lands on Home.
4. Sign out from the Profile tab, then sign back in as the same student with
   a WRONG password → red error snackbar. Then the correct password → Home.
   "Firebase Auth errors are mapped to friendly messages."

## 1:40 – 2:20  Home dashboard
"The home screen greets the user, shows the summary counters for their own
reports and the three most recent ones. These tiles are driven by a Riverpod
StreamProvider on Firestore, so they update live."
Scroll once, point at the stats and recent list, tap *Report an Issue*.

## 2:20 – 3:50  Submit an incident (with photo)
1. Tap *Submit Report* immediately → "Please choose a category" and field
   errors appear.
2. Choose **Water**. Title: "No water in Block B showers". Description: two
   sentences. Location: *Student Residence*, room "2nd floor".
3. Tap *Tap to add a photo* → *Choose from gallery* → pick the image → preview.
   "The picker compresses the image to 1280 px and the app rejects files
   over 5 MB; Storage rules enforce the same limit."
4. Submit → spinner → detail page opens with status **Submitted** and the
   timeline's first step filled in.
5. Switch to the browser tab: Firestore console → `incidents` → the new
   document (point at `status`, `statusHistory`, `photoUrl`, `reporterId`),
   then Storage → `incidents/{uid}/…jpg`.
   "The photo is uploaded first, then the document is written with a server
   timestamp and an audit entry."

## 3:50 – 4:50  Browse, search and filter
1. Reports tab. Scroll the full campus list.
2. Type "water" in search → list narrows. Clear it.
3. Tap status chip **In Progress** → only those. Tap **All**.
4. Tap category chip **Sanitation** → filtered. Combine with a search word.
5. Tap *Clear*. Pull to refresh.
   "Search and filters are a Notifier in Riverpod; the filtered list is a
   derived provider, so no extra Firestore queries are needed."
6. Open any report → point at timeline, description, photo. Back.

## 4:50 – 5:20  My Reports / Profile
Profile tab: profile card with the *Student* badge, personal stats, status
chips filtering only the user's own reports. Open the menu on the new report
→ *Withdraw report* exists only while it is Submitted (cancel the dialog).

## 5:20 – 7:00  Staff workflow (access control)
1. Sign out. Sign in as the **staff** account.
   "Same login screen; the role comes from the user's Firestore profile."
2. Home shows the **STAFF** badge and campus-wide counters.
3. Reports tab → staff banner → open the student's water report.
4. Tap **Update Status** → bottom sheet → **In Progress**, note: "Plumber
   scheduled for tomorrow 9 am" → Save → snackbar; timeline advances and the
   note appears under *Staff Updates*.
5. Firestore console tab: open `firestore.rules` (or the Rules tab) and read
   the `isStaff()` function and the `hasOnly(['status','statusHistory',
   'updatedAt'])` line.
   "Hiding the button isn't security: the rules check the caller's role
   document, and a student client calling the same update gets
   permission-denied. Staff can change only the status fields, never the
   content of a report."

## 7:00 – 7:40  Real-time update on the student side
Keep the staff session open. Sign out, sign in as the student (or use a
second emulator if you have one). Open the same report → status is now
**In Progress** with the staff note, Home counters have moved. Optionally
sign back in as staff and mark it **Resolved**, then show the student's
Resolved counter.

## 7:40 – 8:10  Wrap-up
"To summarise: Firebase Auth for identity, Firestore for real-time data
with role-based security rules, Storage for photos, and Riverpod to keep
screens free of Firebase code and give every action loading and error
states. Tests cover validators, formatting, filtering and the model
serialisation, and run in GitHub Actions. The repository and the technical
report explain the architecture in detail. Thank you."

---

## Recording tips
- macOS: QuickTime → File → New Screen Recording, select the emulator window
  and the browser tab area; microphone on. Or OBS if you want face cam.
- Firebase Studio: use the browser's tab capture (Loom, OBS, or QuickTime on
  the whole screen).
- Speak slower than feels natural; pause for one second after every tap.
- If a step fails, keep recording, redo the step, and trim later (iMovie or
  QuickTime → Edit → Trim).
- Export 1080p, name it `KamyUwambaye_Assignment2_Demo.mp4`, upload to Google
  Drive or YouTube (unlisted) and paste the link into the report PDF.
