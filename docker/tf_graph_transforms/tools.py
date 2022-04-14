import tf2xla_pb2
import cv2
import tensorflow as tf

model_path = 'savedmodel/2/model.savedmodel'
model = tf.keras.models.load_model(model_path)


config = tf2xla_pb2.Config()

batch_size = 1

for x in model.inputs:
    x.set_shape([batch_size] + list(x.shape)[1:])
    feed = config.feed.add()
    feed.id.node_name = x.op.name
    feed.shape.MergeFrom(x.shape.as_proto())

for x in model.outputs:
    fetch = config.fetch.add()
    fetch.id.node_name = x.op.name

with open('graph.config.pbtxt', 'w') as f:
    f.write(str(config))

cv2.dnn.writeTextGraph(
    'savedmodel/2/model.savedmodel/saved_model_frozen.pb',
    'savedmodel/2/model.savedmodel/graph.pbtxt')

# import json
# config_dict = model.get_config()
# with open('config.json', 'w') as f:
#     json.dump(config_dict, f)

# model.save('savedmodel/3/model.savedmodel', compile=False)
# model.save('savedmodel/3/model.savedmodel', as_text=True)
# tf.io.write_graph()
