<!-- expander:image-slot name="hero" placeholder -->
<img width="2048" height="1152" alt="thumby-hero" src="https://github.com/user-attachments/assets/b4b0110c-fec3-403a-af41-7b64cba3b3d4" />
<!-- /expander:image-slot -->

If you make content, you know the feeling. You finish editing a piece of software, or a video, or a project, and the very last hurdle is making a thumbnail. You just need something clean, fast, and striking. So what do most of us do? We open up Photoshop, Figma, or Canva. Those are amazing tools, and I use them all the time. But for a quick text-overlay iteration, they can feel like massive overkill. You are suddenly dealing with layers, complex bounding boxes, canvas resizing, and heavy memory usage just to snap a single word onto an image.

I wanted a frictionless, instant way to test thumbnail ideas. Not a design suite. Not a blank canvas with a thousand options to get lost in. Just a window where I could drop an image, type a word, and see how it looks. So I built a native solution for it. I call it Thumby, a small macOS thumbnail editor for fast text-overlay iteration.

The whole point is to remove the friction between having a thumbnail idea and seeing it on screen. The big tools are powerful, but power is not what I needed at that last step. I needed speed.

## What Thumby Does

Thumby is a lightweight, completely native macOS tool designed specifically for fast text-overlay iteration. Because it is built natively in Swift, it launches instantly and uses barely any resources. The core philosophy is speed through constraints. Instead of handing you a blank slate with infinite options, Thumby focuses on one structured, fluid workflow: drop an image, set a word, pick a look, place it, export. That is the entire surface area, and that is on purpose. It does not try to be a layered design editor, a vector tool, or a full image manipulator. It does one job, which is putting striking text on an image quickly, and it gets out of your way.

## Run

```bash
swift run
```

## Build A macOS App Bundle

```bash
./Scripts/package-app.sh
open .build/release/Thumby.app
```

## How It Works

Here is exactly how the workflow looks when you sit down to use it. First, you drag and drop an image straight into the window, or you pick one from your disk. The window opens to a drop zone, so there is no project setup, no new-document dialog, no canvas dimensions to fill in. The image you bring is the canvas.

Next, you type in your short phrase or keyword. This is the text that will sit on the thumbnail, and the editor treats it as the focus of the whole layout rather than as one more object floating in a scene.

From there is where the structured part of the philosophy shows up. Instead of spending ten minutes hunting through a massive font drop-down list to find something that looks decent, Thumby uses preset visual profiles. You can instantly cycle between three styles: Minimal, Catchy, and Modern. Each profile is a curated starting point, a vibe you can commit to with a single click, so the question shifts from "which of the hundreds of fonts should I use" to "which of these three directions fits this thumbnail."

Once you pick a vibe, you get direct, tactile control over the dials that actually matter. You can toggle uppercase, tweak the text size, restrict the text box width, and change the color. You can also add a picture outline, a border that frames the whole image. By default, the tool matches the outline color to your text to keep things cohesive, so the frame and the words read as one design decision. If you want to get creative, you can unlock the outline and change it independently.

My favorite part to build was the positioning. You grab the text box and drag it directly over the preview image, placing it exactly where it looks right. There is no coordinate field to type into and no alignment menu to dig through. You move the words with your cursor, watch them land, and let go. That tactile placement is the heart of the iteration loop: try a spot, see it, nudge it, done.

<!-- expander:image-slot name="body-1" placeholder -->
<!-- ADD AN IMAGE, either way:
     A) Drop any image file into  docs/images/1/  (any filename), then re-run the skill.
     B) GitHub web editor: delete the <img> line below, click the empty line, paste a screenshot. -->
<img alt="body-1 — PASTE" src="PASTE">
<!-- /expander:image-slot -->
<img width="2048" height="1152" alt="thubmy-1" src="https://github.com/user-attachments/assets/695542f7-74be-4101-9b09-556b2d3acd2b" />

## The Engineering Detail That Makes The Preview Honest

There is a small engineering detail under the hood that makes a large difference in how the tool feels to use. When you work in a lightweight window, you are looking at a scaled-down preview of your image. The actual image might be far larger than the box you are dragging text around in. If you hardcode pixel coordinates against that preview, the final output looks completely wrong when you export it, because the coordinates that made sense at preview scale mean something else entirely at full resolution.

To avoid that, Thumby stores the text placement relative to the image dimensions rather than in absolute preview pixels. The position you drag the text to is recorded as a relationship to the image itself, not to the window. So no matter how large the original high-resolution image is, when you click export, the final PNG matches the layout you saw in the preview, rendered at the original resolution. The preview is not an approximation you have to second-guess. What you place is what you get, at full crispness.

This is the kind of detail you only notice when it is missing. When it works, the preview just feels trustworthy, and you stop thinking about the gap between what you see and what you will ship. That trust is what lets the whole drag-to-place workflow stay fast: you never have to export, check, and come back to fix a placement that drifted.

## Why I Built This

Building Thumby was a good reminder of how satisfying it is to make a hyper-focused tool that does one specific job well. The large design suites are not the problem. The problem is reaching for one of them when all you want is to put a word on an image and see if it lands. That mismatch is where the friction lives, and it is exactly the friction Thumby is built to strip away.

Speed through constraints is not a limitation I worked around. It is the feature. By deciding up front that there would be three profiles instead of an open font picker, and a handful of dials instead of an endless panel of options, the tool removes the analysis paralysis that comes with a blank slate. You are not configuring an editor. You are iterating on an idea, and the iteration happens in seconds.

Going native in Swift was part of the same decision. A tool meant to feel instant has to actually be instant, so it launches immediately and stays light. Every choice in Thumby points back at the same goal: shorten the distance between a thumbnail idea and seeing it on screen.

<!-- expander:image-slot name="body-2" placeholder -->
<!-- ADD AN IMAGE, either way:
     A) Drop any image file into  docs/images/2/  (any filename), then re-run the skill.
     B) GitHub web editor: delete the <img> line below, click the empty line, paste a screenshot. -->
<img alt="body-2 — PASTE" src="PASTE">
<!-- /expander:image-slot -->
<img width="2048" height="1152" alt="thumby-2" src="https://github.com/user-attachments/assets/3aa4a584-7990-4f80-90c9-5a5d77c6e932" />

## When To Reach For Thumby

Thumby is built for a specific moment, not for every image task. Reach for it when:

- You make content and need a clean, fast, striking thumbnail at the end of a project.
- You want to iterate on a text overlay quickly, trying a word and a look in seconds.
- You are on a Mac and want a native tool that launches instantly and stays light.
- You would rather pick from a few curated profiles than hunt through a font list.

It is deliberately not the tool for everything. If you need layers, vector editing, complex compositing, or the full control of a design suite, the big tools are still the right call, and I still use them. Thumby is for the last-hurdle case: image in, word on, placed by hand, exported as a PNG.

I have made the project entirely open-source on GitHub. If you are on a Mac and want to try it, you can run it instantly with `swift run`, or use the included package script to build a native `.app` bundle for your Applications folder. Take a look, try it out, and let me know what you think.

## Built with Claude Code

This tool was designed, written, and iterated on with [Claude Code](https://claude.com/claude-code) as the primary author.

<!-- expander:v1 -->
