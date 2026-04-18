import os
from moviepy import VideoFileClip

def convert_ogv_to_mp4(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.ogv'):
                ogv_path = os.path.join(root, file)
                mp4_path = os.path.join(root, file.replace('.ogv', '.mp4'))
                
                print(f"Converting {ogv_path} to MP4...")
                
                try:
                    clip = VideoFileClip(ogv_path)
                    clip.write_videofile(mp4_path, codec="libx264", audio_codec="aac")
                    clip.close()
                    
                    # Delete the original OGV file after successful conversion
                    os.remove(ogv_path)
                    print(f"Successfully converted and removed: {file}")
                except Exception as e:
                    print(f"Failed to convert {file}: {e}")

if __name__ == "__main__":
    assets_dir = r"D:\Coding\flutter\trutouch\assets"
    convert_ogv_to_mp4(assets_dir)
