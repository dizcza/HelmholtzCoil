import warnings
from collections import namedtuple

import magpylib as magpy
import matplotlib.pyplot as plt
import numpy as np
from magpylib.current import Loop

Mu0 = 4 * np.pi * 1e-7

LitzWire = namedtuple("LitzWire", ("d_outer", "d_strand", "n"))

WireSingle = LitzWire(d_outer=1.3, d_strand=1.0, n=1)  # one strand single wire
LITZ_75 = LitzWire(d_outer=1.3, d_strand=0.1, n=75)
LITZ_150 = LitzWire(d_outer=1.76, d_strand=0.1, n=150)


class HelmholtzCoil(magpy.Collection):
    def __init__(self, wire: LitzWire, radius=130, current=2, wires=6,
                 layers=8, fast=True):
        """
        Helmholtz coil object.

        Parameters
        ----------
        wire : LitzWire
            A Litz wire or a simple wire.
        radius : float
            The radius of a coil in mm.
        current : float
            The applied current in A.
        wires : int
            No. of wires in a layer.
        layers : int
            No. of stacked layers with ``wires``.
            Even no. of layers end up winding on the same side of a coil,
            odd - opposite sides.
        fast : bool
            True to assume that the coil is a set of closed loop currents.
            False to compute the spiral wire layout (has negligible effect).
        """
        super().__init__()
        self.wire = wire
        self.radius = radius
        self.current = current
        self.n_wires = wires
        self.n_layers = layers
        self.build(fast)

    def build(self, fast):
        assert self.wiring_width < self.radius / 2
        if fast:
            coil1 = self._coil_loop()
        else:
            coil1 = self._coil_spiral()
        coil1.position = (0, 0, -self.radius / 2)
        coil2 = coil1.copy(position=(0, 0, self.radius / 2))
        self.add(coil1, coil2)
        self.add_coils_connection_cables(coil1, coil2)

    @property
    def n_turns(self):
        return self.n_layers * self.n_wires

    @property
    def wiring_height(self):
        return self.wire.d_outer * self.n_layers

    @property
    def wiring_width(self):
        return self.wire.d_outer * self.n_wires

    @property
    def wiring_height_packed(self):
        return self.wire.d_outer * (1 + 0.87 * (self.n_layers - 1))

    @property
    def wire_length(self):
        length_mm = 2 * np.pi * self.radius * self.n_layers * self.n_wires * 2 + 2 * self.radius
        return length_mm / 1e3

    @property
    def wire_weight(self):
        copper_density = 8960
        area = np.pi * (self.wire.d_strand * 0.5e-3) ** 2
        volume = area * self.wire_length * self.wire.n
        m = copper_density * volume
        return m

    @property
    def inductance(self):
        L_coil = 0.8 * (self.radius * self.n_turns) ** 2 / (
                6 * self.radius + 9 * self.wiring_width + 10 * self.wiring_height)
        # convert mm to inches, uH to H
        L_coil /= (25.4 * 1e6)
        L_helmholtz = 2 * L_coil
        return L_helmholtz

    @property
    def resistance(self):
        copper_resistivity = 0.0172
        area = np.pi * (self.wire.d_strand / 2) ** 2
        r = copper_resistivity * self.wire_length / area
        r /= self.wire.n
        return r

    def resistance_reactive(self, f=1000):
        omega = 2 * np.pi * f
        r = np.sqrt(self.resistance ** 2 + (omega * self.inductance) ** 2)
        return r

    def physical_size(self, pad_mm=3):
        return 2 * (self.radius + self.wiring_height / 2 + pad_mm)

    def __repr__(self):
        tol = 0.01
        b0_width = self.get_homogeneous_region_width(tol=tol)
        r_inner = self.radius - self.wiring_height / 2
        w_packed = self.wiring_width + self.wire.d_outer / 2
        if self.n_layers % 2 == 0:
            winding = 'same side'
        else:
            winding = 'opposite sides'
        s = f"Mechanics\n" \
            f"\tRadius: {self.radius} (inner {r_inner:.2f}) mm\n" \
            f"\t{self.n_layers} layers (H={self.wiring_height:.2f}) " \
            f"of {self.n_wires} wires (W={self.wiring_width:.2f})\n" \
            f"\tPacked winding (mm): H={self.wiring_height_packed:.2f}, " \
            f"W={w_packed:.2f}\n" \
            f"\tWinding enter & exit: {winding}\n" \
            f"\tWire L={self.wire_length:.2f} m, M={self.wire_weight:.3f} kg\n" \
            f"\t     Litz {self.wire.d_strand} mm x {self.wire.n} strands\n" \
            f"\tPhysical diameter: {self.physical_size():.1f} mm\n" \
            f"Circuit\n" \
            f"\tResistance DC: {self.resistance:.2f} Ohm\n" \
            f"\tResistance 1kHz: {self.resistance_reactive(f=1000):.2f} Ohm\n" \
            f"\tInductance: {self.inductance * 1e3:.2f} mH\n" \
            f"\tCurrent: {self.current} A\n" \
            f"Magnetics\n" \
            f"\tB0 at center: {self.calc_b0():.3f} mT\n" \
            f"\tHomogeneous region (tol={tol}): {b0_width:.0f} mm"
        return s

    def add_coils_connection_cables(self, coil1, coil2):
        # Has negligible effect
        wire1, wire2, wire3 = coil1.sources[-1], coil2.sources[0], \
                              coil2.sources[-1]
        if isinstance(wire1, magpy.current.Loop):
            v1_end = [wire1.diameter / 2, 0, 0] + wire1.position
            v2_begin = [wire2.diameter / 2, 0, 0] + wire2.position
            v2_end = [wire3.diameter / 2, 0, 0] + wire3.position
        else:
            v1_end = wire1.vertices[-1] + coil1.position
            v2_begin = wire2.vertices[0] + coil2.position
            v2_end = wire3.vertices[-1] + coil2.position
        cable1 = magpy.current.Line(
            current=self.current,
            vertices=np.stack([v1_end, v2_begin])
        )
        cable2 = magpy.current.Line(
            current=self.current,
            vertices=np.stack([v2_end, v1_end])
        )
        self.add(cable1, cable2)

    def layer_radius(self, layer_id):
        x_layer = self.wire.d_outer * (layer_id - (self.n_layers - 1) / 2)
        return self.radius + x_layer

    def _coil_loop(self):
        coil1 = magpy.Collection(style_label='coil1')
        for layer_id in range(self.n_layers):
            loop_diameter = 2 * self.layer_radius(layer_id)
            for wire_id in range(self.n_wires):
                z_wire = self.wire.d_outer * (wire_id - (self.n_wires - 1) / 2)
                coil1.add(Loop(current=self.current, diameter=loop_diameter,
                               position=(0, 0, z_wire)))
        return coil1

    def _coil_spiral(self):
        coil1 = magpy.Collection(style_label='coil1')
        phase = np.linspace(0, self.n_wires * 2 * np.pi, num=1000)
        half_width = self.wire.d_outer * (self.n_wires - 1) / 2
        z_ticks = np.linspace(-half_width, half_width, phase.size)
        for layer_id in range(self.n_layers):
            loop_radius = self.layer_radius(layer_id)
            vertices = np.c_[loop_radius * np.cos(phase),
                             loop_radius * np.sin(phase),
                             z_ticks]
            coil_layer = magpy.current.Line(
                current=self.current,
                vertices=vertices
            )
            coil1.add(coil_layer)
        return coil1

    def calc_b0(self):
        # Calculate the magnetic field in the center.
        b0 = 8 / (5 * 5**0.5) * Mu0 * self.n_turns * self.current / self.radius
        # convert radius mm to m, T to mT
        b0_mT = b0 * 1e6
        return b0_mT

    def create_grid(self, n=100, dim=2):
        grid_z = np.linspace(-self.radius, self.radius, num=n)
        grid = np.zeros((grid_z.shape[0], 3))
        grid[:, dim] = grid_z
        return grid

    def get_homogeneous_region(self, B, dim=2, tol=0.01):
        Bz = B[:, dim]
        B0 = Bz[B.shape[0] // 2]
        Bz_norm = Bz / B0
        idx_valid = np.nonzero(np.abs(Bz_norm - 1) < tol)[0]
        if np.unique(np.diff(idx_valid)).size != 1:
            warnings.warn("Non-convex B field")
        left, right = idx_valid[0], idx_valid[-1]
        return left, right

    def get_homogeneous_region_width(self, tol=0.01):
        grid = self.create_grid()
        B = self.getB(grid)
        left, right = self.get_homogeneous_region(B, tol=tol)
        z_left, z_right = grid[left, 2], grid[right, 2]
        z_width = z_right - z_left
        return z_width


def calc_mechanical_tolerance(coil_rot=1., axis_dx=1.):
    """
    Calculate tolerance error for the magnetic field B induced by coil
    misplacement and rotation.

    See "Design and construction of a 3D Helmholtz coil system for the ALBA
    magnetic measurements laboratory" by Andrea del Carme Fontanet Valls.

    https://upcommons.upc.edu/bitstream/handle/2117/168009/Memoria_TFG-Andrea%20Fontanet.pdf?sequence=4&isAllowed=y

    Parameters
    ----------
    coil_rot : float
        Max vertical rotation in degrees for one of the coils.
    axis_dx : float
        Max center displacement in mm for one of the coils.

    Returns
    -------
    tol : float
        Tolerance error for the system of two coils
    """
    tol_rot = 11.2 * np.deg2rad(coil_rot)
    tol_displacement = 0.00898328 * axis_dx + 0.000861055 * axis_dx ** 2
    tol_percent = tol_rot + tol_displacement
    # Two coils, multiply by 2
    return 2 * tol_percent / 100.


def plot_streamplot(helmholtz: HelmholtzCoil, ax, dim=(0, 2)):
    ts = np.linspace(-2 * helmholtz.radius, 2 * helmholtz.radius, 100)
    grid = np.zeros((ts.shape[0], ts.shape[0], 3), dtype=np.float32)
    grid[:, :, dim] = np.stack(np.meshgrid(ts, ts), axis=2)
    dim_x, dim_y = dim
    dim_labels = 'xyz'

    B = helmholtz.getB(grid)
    Bamp = np.linalg.norm(B, axis=2)
    Bamp_norm = Bamp / np.amax(Bamp)

    sp = ax.streamplot(
        grid[:, :, dim_x], grid[:, :, dim_y], B[:, :, dim_x], B[:, :, dim_y],
        density=2,
        color=Bamp,
        linewidth=np.sqrt(Bamp_norm) * 2,
        cmap='coolwarm',
    )
    ax.set(
        xlabel=f'{dim_labels[dim_x]}, mm',
        ylabel=f'{dim_labels[dim_y]}, mm'
    )

    plt.colorbar(sp.lines, ax=ax, label='[mT]')


def plot_Bz(helmholtz: HelmholtzCoil, ax, dim=2, tol=0.01):
    grid = helmholtz.create_grid(dim=dim)
    B = helmholtz.getB(grid)
    ax.plot(grid, B, label=['Bx', 'By', 'Bz'])

    Bz = B[:, dim]
    B0 = Bz[B.shape[0] // 2]
    print(f"\n{B0=:.5f}, expected {helmholtz.calc_b0():.5f}")
    left, right = helmholtz.get_homogeneous_region(B, dim=dim, tol=tol)
    z_left, z_right = grid[left, 2], grid[right, 2]
    z_width = z_right - z_left
    ax.vlines(x=[z_left, z_right], ymin=B.min(),
                 ymax=[Bz[left], Bz[right]],
                 linestyles='--', colors='grey', alpha=0.5)
    ax.text(0.5, 0.5, f"Tolerance {tol}\nwidth {int(z_width)} mm",
               transform=ax.transAxes, horizontalalignment='center',
               verticalalignment='center')

    xlabel = 'xyz'[dim]
    ax.set(
        xlabel=f'{xlabel}, mm',
        ylabel='B-field, mT'
    )
    ax.grid(color='.9')
    ax.legend()


# print(calc_mechanical_tolerance())

helmholtz = HelmholtzCoil(wire=LITZ_75)
print(helmholtz)

magpy.show(*helmholtz, backend='plotly')

fig, axes = plt.subplots(nrows=2)
axes = np.atleast_1d(axes)

plot_streamplot(helmholtz, axes[0])
plot_Bz(helmholtz, axes[-1])

plt.tight_layout()
plt.show()
